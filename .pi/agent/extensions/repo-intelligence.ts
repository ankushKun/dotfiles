import { execFile } from "node:child_process";
import { createHash } from "node:crypto";
import * as fs from "node:fs/promises";
import * as path from "node:path";
import { promisify } from "node:util";
import { StringEnum } from "@earendil-works/pi-ai";
import { getAgentDir, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const run = promisify(execFile);
const MAX_FILES = 8000;
const MAX_SOURCE_BYTES = 192 * 1024;
const SOURCE_EXTENSIONS = new Set([
	".c", ".cc", ".cpp", ".cs", ".css", ".go", ".h", ".hpp", ".html", ".java", ".js", ".jsx",
	".json", ".kt", ".lua", ".md", ".php", ".py", ".rb", ".rs", ".scss", ".sh", ".sql", ".svelte",
	".swift", ".toml", ".ts", ".tsx", ".vue", ".xml", ".yaml", ".yml",
]);
const RESOLVE_EXTENSIONS = [".ts", ".tsx", ".js", ".jsx", ".py", ".go", ".rs", ".vue", ".svelte", ".json"];

interface FileNode {
	path: string;
	ext: string;
	bytes: number;
	lines: number;
	symbols: string[];
}

interface GraphEdge {
	from: string;
	to: string;
	kind: "imports";
}

interface RepoIndex {
	version: 1;
	cwd: string;
	generatedAt: string;
	files: FileNode[];
	edges: GraphEdge[];
	languages: Record<string, number>;
}

function cachePath(cwd: string): string {
	const key = createHash("sha256").update(cwd).digest("hex").slice(0, 20);
	return path.join(getAgentDir(), "cache", "repo-index", `${key}.json`);
}

function normalize(file: string): string {
	return file.split(path.sep).join("/").replace(/^\.\//, "");
}

function language(ext: string): string {
	return ({
		".ts": "TypeScript", ".tsx": "TypeScript", ".js": "JavaScript", ".jsx": "JavaScript",
		".py": "Python", ".go": "Go", ".rs": "Rust", ".java": "Java", ".kt": "Kotlin",
		".c": "C", ".h": "C", ".cc": "C++", ".cpp": "C++", ".hpp": "C++", ".cs": "C#",
		".rb": "Ruby", ".php": "PHP", ".swift": "Swift", ".vue": "Vue", ".svelte": "Svelte",
		".sh": "Shell", ".sql": "SQL", ".md": "Markdown", ".json": "JSON", ".yaml": "YAML", ".yml": "YAML",
	} as Record<string, string>)[ext] ?? ext.slice(1).toUpperCase() ?? "Other";
}

function extractSymbols(source: string, ext: string): string[] {
	const patterns = ext === ".py"
		? [/^\s*(?:async\s+)?def\s+([A-Za-z_]\w*)/gm, /^\s*class\s+([A-Za-z_]\w*)/gm]
		: ext === ".go"
			? [/^func\s+(?:\([^)]*\)\s*)?([A-Za-z_]\w*)/gm, /^type\s+([A-Za-z_]\w*)/gm]
			: ext === ".rs"
				? [/^\s*(?:pub\s+)?(?:async\s+)?fn\s+([A-Za-z_]\w*)/gm, /^\s*(?:pub\s+)?(?:struct|enum|trait)\s+([A-Za-z_]\w*)/gm]
				: [
					/^\s*(?:export\s+)?(?:default\s+)?(?:async\s+)?function\s+([A-Za-z_$][\w$]*)/gm,
					/^\s*(?:export\s+)?(?:default\s+)?(?:class|interface|type|enum)\s+([A-Za-z_$][\w$]*)/gm,
					/^\s*(?:export\s+)?(?:const|let|var)\s+([A-Za-z_$][\w$]*)/gm,
				];
	const found = new Set<string>();
	for (const pattern of patterns) {
		for (const match of source.matchAll(pattern)) {
			found.add(match[1]);
			if (found.size >= 40) return [...found];
		}
	}
	return [...found];
}

function extractImports(source: string, ext: string): string[] {
	const specs = new Set<string>();
	const patterns = ext === ".py"
		? [/^\s*from\s+([.\w]+)\s+import\s+/gm, /^\s*import\s+([.\w]+)/gm]
		: [
			/(?:import|export)[\s\S]*?\bfrom\s*["']([^"']+)["']/g,
			/\brequire\(\s*["']([^"']+)["']\s*\)/g,
			/\bimport\(\s*["']([^"']+)["']\s*\)/g,
		];
	for (const pattern of patterns) for (const match of source.matchAll(pattern)) specs.add(match[1]);
	return [...specs];
}

function resolveImport(from: string, spec: string, files: Set<string>): string | undefined {
	if (!spec.startsWith(".")) return undefined;
	const base = normalize(path.posix.normalize(path.posix.join(path.posix.dirname(from), spec)));
	const candidates = [base, ...RESOLVE_EXTENSIONS.map((ext) => base + ext), ...RESOLVE_EXTENSIONS.map((ext) => `${base}/index${ext}`)];
	return candidates.find((candidate) => files.has(candidate));
}

const IGNORE_GLOBS = [
	"!.git", "!node_modules", "!vendor", "!dist", "!build", "!target", "!.next", "!.cache", "!coverage",
	// Home-directory / toolchain noise that can make `rg --files` exceed process maxBuffer
	"!Library", "!Music", "!Movies", "!Pictures", "!Downloads", "!.Trash",
	"!.cargo", "!.rustup", "!.npm", "!.cache", "!.local/share", "!.local/lib",
	"!go/pkg", "!.cli", "!.hermes", "!.claude", "!.codex", "!.cursor",
];

async function listFiles(cwd: string): Promise<string[]> {
	try {
		const { stdout } = await run("rg", [
			"--files", "--hidden", "--no-messages",
			...IGNORE_GLOBS.flatMap((glob) => ["-g", glob]),
		], { cwd, maxBuffer: 32 * 1024 * 1024, encoding: "utf8" });
		return stdout.split("\n").filter(Boolean).slice(0, MAX_FILES).map(normalize);
	} catch (error) {
		const code = (error as { code?: string }).code;
		if (code === "ERR_CHILD_PROCESS_STDIO_MAXBUFFER") {
			throw new Error(`Repository too large to index from ${cwd}; open a project directory or run /index from a smaller tree.`);
		}
		throw error;
	}
}

async function buildIndex(cwd: string): Promise<RepoIndex> {
	const allFiles = await listFiles(cwd);
	const sourceFiles = allFiles.filter((file) => SOURCE_EXTENSIONS.has(path.extname(file).toLowerCase()));
	const fileSet = new Set(allFiles);
	const files: FileNode[] = [];
	const edges: GraphEdge[] = [];
	const languages: Record<string, number> = {};
	let cursor = 0;

	await Promise.all(Array.from({ length: Math.min(16, sourceFiles.length) }, async () => {
		while (cursor < sourceFiles.length) {
			const file = sourceFiles[cursor++];
			try {
				const absolute = path.join(cwd, file);
				const stat = await fs.stat(absolute);
				if (stat.size > MAX_SOURCE_BYTES) continue;
				const source = await fs.readFile(absolute, "utf8");
				const ext = path.extname(file).toLowerCase();
				files.push({ path: file, ext, bytes: stat.size, lines: source.split("\n").length, symbols: extractSymbols(source, ext) });
				languages[language(ext)] = (languages[language(ext)] ?? 0) + 1;
				for (const spec of extractImports(source, ext)) {
					const target = resolveImport(file, spec, fileSet);
					if (target) edges.push({ from: file, to: target, kind: "imports" });
				}
			} catch {
				// Files can disappear while an agent or watcher is editing the tree.
			}
		}
	}));

	files.sort((a, b) => a.path.localeCompare(b.path));
	const index: RepoIndex = { version: 1, cwd, generatedAt: new Date().toISOString(), files, edges, languages };
	const target = cachePath(cwd);
	await fs.mkdir(path.dirname(target), { recursive: true });
	await fs.writeFile(target, `${JSON.stringify(index)}\n`, { mode: 0o600 });
	return index;
}

function rankedSummary(index: RepoIndex): string {
	const dirs = new Map<string, number>();
	const degree = new Map<string, number>();
	for (const file of index.files) dirs.set(file.path.split("/")[0] || ".", (dirs.get(file.path.split("/")[0] || ".") ?? 0) + 1);
	for (const edge of index.edges) {
		degree.set(edge.from, (degree.get(edge.from) ?? 0) + 1);
		degree.set(edge.to, (degree.get(edge.to) ?? 0) + 1);
	}
	const top = <T>(items: [string, number][], n: number) => items.sort((a, b) => b[1] - a[1]).slice(0, n).map(([k, v]) => `${k} (${v})`).join(", ");
	return [
		`Indexed ${index.files.length} source files and ${index.edges.length} import edges at ${index.generatedAt}.`,
		`Languages: ${top(Object.entries(index.languages), 8) || "none"}`,
		`Top areas: ${top([...dirs], 10) || "none"}`,
		`Graph hubs: ${top([...degree], 10) || "none"}`,
	].join("\n");
}

function queryIndex(index: RepoIndex, mode: string, query: string, limit: number): string {
	if (mode === "summary") return rankedSummary(index);
	const needle = query.toLowerCase();
	const matches = index.files.filter((file) => file.path.toLowerCase().includes(needle) || file.symbols.some((symbol) => symbol.toLowerCase().includes(needle)));
	const paths = new Set(matches.map((file) => file.path));
	if (mode === "symbols") {
		return matches.slice(0, limit).map((file) => `${file.path}: ${file.symbols.join(", ") || "(no indexed symbols)"}`).join("\n") || "No matches.";
	}
	if (mode === "dependencies" || mode === "dependents") {
		const selected = matches.slice(0, Math.max(1, Math.min(limit, 20)));
		const lines: string[] = [];
		for (const file of selected) {
			const related = index.edges.filter((edge) => mode === "dependencies" ? edge.from === file.path : edge.to === file.path);
			lines.push(`${file.path}\n${related.slice(0, limit).map((edge) => `  ${mode === "dependencies" ? "→" : "←"} ${mode === "dependencies" ? edge.to : edge.from}`).join("\n") || "  (none indexed)"}`);
		}
		return lines.join("\n") || "No matching files.";
	}
	const adjacent = index.edges.filter((edge) => paths.has(edge.from) || paths.has(edge.to));
	return [
		...matches.slice(0, limit).map((file) => `${file.path} [${file.symbols.slice(0, 8).join(", ")}]`),
		...adjacent.slice(0, limit).map((edge) => `${edge.from} → ${edge.to}`),
	].slice(0, limit).join("\n") || "No matches.";
}

export default function repoIntelligence(pi: ExtensionAPI): void {
	let current: RepoIndex | undefined;
	let building: Promise<RepoIndex> | undefined;
	let rebuildTimer: NodeJS.Timeout | undefined;
	let activeCwd = "";
	const setStatus = (ctx: ExtensionContext, color: "warning" | "success" | "error", text: string) => {
		try {
			ctx.ui.setStatus("repo-index", ctx.ui.theme.fg(color, text));
		} catch {
			// Background indexing may finish after a session replacement or shutdown.
		}
	};

	const refresh = async (ctx: ExtensionContext) => {
		if (building) return building;
		setStatus(ctx, "warning", "indexing…");
		building = buildIndex(ctx.cwd).then((result) => {
			current = result;
			setStatus(ctx, "success", `map ${result.files.length}`);
			return result;
		}).catch((error) => {
			setStatus(ctx, "error", "index failed");
			// Swallow so a failed background index never crashes the TUI (e.g. indexing $HOME).
			console.error(`[repo-intelligence] ${error instanceof Error ? error.message : error}`);
			if (current?.cwd === ctx.cwd) return current;
			const empty: RepoIndex = {
				version: 1,
				cwd: ctx.cwd,
				generatedAt: new Date().toISOString(),
				files: [],
				edges: [],
				languages: {},
			};
			current = empty;
			return empty;
		}).finally(() => { building = undefined; });
		return building;
	};

	const ensure = async (ctx: ExtensionContext) => current?.cwd === ctx.cwd ? current : refresh(ctx);

	pi.on("session_start", async (_event, ctx) => {
		activeCwd = ctx.cwd;
		try {
			const cached = JSON.parse(await fs.readFile(cachePath(ctx.cwd), "utf8")) as RepoIndex;
			if (cached.version === 1 && cached.cwd === ctx.cwd) current = cached;
		} catch { /* first visit */ }
		void refresh(ctx);
	});

	pi.on("tool_result", async (event, ctx) => {
		if ((event.toolName !== "edit" && event.toolName !== "write") || event.isError) return;
		if (rebuildTimer) clearTimeout(rebuildTimer);
		rebuildTimer = setTimeout(() => { if (ctx.cwd === activeCwd) void refresh(ctx); }, 700);
	});

	pi.on("before_agent_start", async (event, ctx) => {
		const index = await ensure(ctx).catch(() => undefined);
		if (!index) return;
		return { systemPrompt: `${event.systemPrompt}\n\nRepository intelligence: an automatic map currently covers ${index.files.length} source files and ${index.edges.length} dependency edges. Use repo_map for architecture, symbol, dependency, and dependent lookups; confirm decisions by reading source.` };
	});

	pi.on("session_shutdown", async () => {
		if (rebuildTimer) clearTimeout(rebuildTimer);
	});

	pi.registerTool({
		name: "repo_map",
		label: "Repo map",
		description: "Query the automatic codebase file/symbol/dependency knowledge graph. Use before broad codebase exploration.",
		parameters: Type.Object({
			mode: Type.Optional(StringEnum(["summary", "search", "symbols", "dependencies", "dependents"] as const)),
			query: Type.Optional(Type.String({ description: "Path or symbol fragment; optional for summary" })),
			limit: Type.Optional(Type.Integer({ minimum: 1, maximum: 100 })),
		}),
		async execute(_id, params, _signal, _update, ctx) {
			const index = await ensure(ctx);
			const mode = params.mode ?? (params.query ? "search" : "summary");
			const text = queryIndex(index, mode, params.query ?? "", params.limit ?? 30);
			return { content: [{ type: "text", text: text.slice(0, 16000) }], details: { mode, generatedAt: index.generatedAt } };
		},
	});

	pi.registerCommand("index", {
		description: "Show status or rebuild the automatic repository map",
		handler: async (args, ctx) => {
			if (args.trim() === "rebuild") current = undefined;
			const index = args.trim() === "rebuild" ? await refresh(ctx) : await ensure(ctx);
			ctx.ui.notify(rankedSummary(index), "info");
		},
	});

	pi.registerCommand("map", {
		description: "Search the repository knowledge graph: /map <path-or-symbol>",
		handler: async (args, ctx) => {
			const index = await ensure(ctx);
			ctx.ui.notify(queryIndex(index, args.trim() ? "search" : "summary", args.trim(), 25), "info");
		},
	});
}
