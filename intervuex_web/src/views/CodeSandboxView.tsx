import React, { useState } from 'react';
import { useTheme } from '../context/ThemeContext';
import type { QuestionItem } from '../types';
import { MOCK_QUESTIONS } from '../mockData';
import { 
  Play, 
  RotateCcw, 
  Copy, 
  Wand2, 
  CheckCircle, 
  Clock, 
  Cpu, 
  HardDrive, 
  Lightbulb, 
  Check, 
  Code2
} from 'lucide-react';

interface CodeSandboxViewProps {
  selectedQuestion?: QuestionItem | null;
}

export const CodeSandboxView: React.FC<CodeSandboxViewProps> = ({ selectedQuestion }) => {
  const { mode, colors } = useTheme();

  const activeQuestion = selectedQuestion || MOCK_QUESTIONS[0];

  const [language, setLanguage] = useState<string>('Python 3');
  const [code, setCode] = useState<string>(
    activeQuestion.codeExample || `# Python 3 Solution for ${activeQuestion.title}\ndef solution():\n    pass`
  );
  const [isExecuting, setIsExecuting] = useState<boolean>(false);
  const [executionResult, setExecutionResult] = useState<any | null>(null);

  // Snippets
  const getSnippets = () => {
    switch (language) {
      case 'PostgreSQL':
        return ['SELECT', 'FROM', 'WHERE', 'JOIN', 'GROUP BY', 'ORDER BY', 'COUNT()'];
      case 'JavaScript':
        return ['const', 'function', 'return', 'console.log()', '=>', 'async/await'];
      case 'Java':
        return ['public', 'class', 'return', 'System.out.println()', 'int', 'String'];
      default:
        return ['def', 'return', 'for in range()', 'print()', 'len()', 'self'];
    }
  };

  const insertSnippet = (snippet: string) => {
    setCode((prev) => prev + `\n${snippet} `);
  };

  const handleRunCode = () => {
    setIsExecuting(true);
    setExecutionResult(null);

    setTimeout(() => {
      setIsExecuting(false);
      setExecutionResult({
        success: true,
        testsPassedCount: 3,
        totalTestsCount: 3,
        executionTimeMs: 42,
        timeComplexity: 'O(V + E)',
        spaceComplexity: 'O(V)',
        codeCritique: 'Optimal DFS state array implementation. No unneeded recursion depth stack allocations. Handles disconnected components correctly.',
        testResults: [
          { input: 'V=4, Adj=[[1],[2],[3],[]]', output: 'False', passed: true },
          { input: 'V=3, Adj=[[1],[2],[0]]', output: 'True (Cycle Detected)', passed: true },
          { input: 'V=2, Adj=[[1],[0]]', output: 'True (Cycle Detected)', passed: true },
        ]
      });
    }, 1200);
  };

  const lines = code.split('\n');

  return (
    <div className="space-y-6 pb-12">
      {/* Sandbox Header */}
      <div className={`p-6 rounded-2xl border flex flex-col md:flex-row items-start md:items-center justify-between gap-4 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold px-2.5 py-0.5 rounded bg-amber-500/15 text-amber-500 border border-amber-500/20">
              {activeQuestion.difficulty}
            </span>
            <span className="text-xs font-bold px-2.5 py-0.5 rounded bg-sky-500/15 text-sky-500">
              {activeQuestion.source}
            </span>
            <span className="text-xs text-slate-400 font-semibold">{activeQuestion.complexity}</span>
          </div>
          <h1 className="font-heading font-extrabold text-xl sm:text-2xl">{activeQuestion.title}</h1>
          <p className={`text-xs max-w-3xl ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
            {activeQuestion.description}
          </p>
        </div>

        {/* Language Selector */}
        <div className="flex items-center gap-3 self-end md:self-auto">
          <label className="text-xs font-bold text-slate-400">Language:</label>
          <select
            value={language}
            onChange={(e) => setLanguage(e.target.value)}
            className={`px-3 py-1.5 rounded-lg border text-xs font-bold outline-none cursor-pointer ${
              mode === 'dark' ? 'bg-[#0B0F19] border-[#334155] text-white' : 'bg-[#F8FAFC] border-[#CBD5E1] text-slate-900'
            }`}
          >
            <option value="Python 3">Python 3</option>
            <option value="JavaScript">JavaScript</option>
            <option value="Java">Java</option>
            <option value="PostgreSQL">PostgreSQL (SQL)</option>
          </select>
        </div>
      </div>

      {/* IDE Editor Panel */}
      <div className={`rounded-2xl border overflow-hidden shadow-2xl ${
        mode === 'dark' ? 'bg-[#0D1117] border-[#30363D]' : 'bg-white border-[#E2E8F0]'
      }`}>
        {/* Language Snippet Toolbar */}
        <div className={`px-4 py-2 border-b flex items-center gap-2 overflow-x-auto ${
          mode === 'dark' ? 'bg-[#161B22] border-[#30363D]' : 'bg-[#F1F5F9] border-[#E2E8F0]'
        }`}>
          <span className="text-xs font-bold text-slate-400 mr-2 flex items-center gap-1">
            <Code2 className="w-3.5 h-3.5" /> Snippets:
          </span>
          {getSnippets().map((snippet, i) => (
            <button
              key={i}
              onClick={() => insertSnippet(snippet)}
              className={`px-2.5 py-1 rounded text-xs font-code font-bold transition-all ${
                mode === 'dark' 
                  ? 'bg-[#21262D] hover:bg-[#30363D] text-sky-400 border border-[#30363D]' 
                  : 'bg-white hover:bg-slate-200 text-sky-600 border border-[#CBD5E1]'
              }`}
            >
              {snippet}
            </button>
          ))}
        </div>

        {/* Editor Surface with Line Numbers Gutter */}
        <div className="flex items-stretch min-h-[380px] font-code text-sm">
          {/* Gutter */}
          <div className={`w-12 py-3 pr-3 text-right select-none font-code text-xs border-r ${
            mode === 'dark' ? 'bg-[#161B22] border-[#30363D] text-[#484F58]' : 'bg-[#F1F5F9] border-[#E2E8F0] text-[#94A3B8]'
          }`}>
            {lines.map((_, idx) => (
              <div key={idx} className="leading-6">{idx + 1}</div>
            ))}
          </div>

          {/* Text Area Code Editor */}
          <textarea
            value={code}
            onChange={(e) => setCode(e.target.value)}
            className={`flex-1 p-3 font-code leading-6 bg-transparent border-none outline-none resize-none ${
              mode === 'dark' ? 'text-[#E2E8F0]' : 'text-[#0F172A]'
            }`}
            spellCheck={false}
          />
        </div>

        {/* Status Bar */}
        <div className={`px-4 py-2 border-t flex flex-wrap items-center justify-between text-xs font-code gap-4 ${
          mode === 'dark' ? 'bg-[#161B22] border-[#30363D] text-slate-400' : 'bg-[#F1F5F9] border-[#E2E8F0] text-slate-600'
        }`}>
          <div className="flex items-center gap-3">
            <span className="font-bold text-emerald-500">{language}</span>
            <span>•</span>
            <span>Ln {lines.length}, Col 1</span>
            <span>•</span>
            <span>{lines.length} lines ({code.length} chars)</span>
          </div>

          <div className="flex items-center gap-3">
            <button 
              onClick={() => alert('Code auto-formatted!')}
              className="flex items-center gap-1 hover:text-white font-bold"
            >
              <Wand2 className="w-3.5 h-3.5" /> Format
            </button>
            <button 
              onClick={() => navigator.clipboard.writeText(code)}
              className="flex items-center gap-1 hover:text-white font-bold"
            >
              <Copy className="w-3.5 h-3.5" /> Copy
            </button>
            <button 
              onClick={() => setCode(activeQuestion.codeExample || '')}
              className="flex items-center gap-1 text-amber-500 hover:underline font-bold"
            >
              <RotateCcw className="w-3.5 h-3.5" /> Reset
            </button>
          </div>
        </div>
      </div>

      {/* Run Execution Controls */}
      <div className="flex items-center justify-between">
        <button
          onClick={handleRunCode}
          disabled={isExecuting}
          className="px-8 py-3.5 rounded-xl font-bold text-sm text-white shadow-xl flex items-center gap-2 transition-transform active:scale-98 disabled:opacity-50"
          style={{ background: colors.gradient }}
        >
          <Play className="w-4 h-4 fill-white" />
          <span>{isExecuting ? 'Executing Tests...' : '▶ RUN CODE & TEST CASES'}</span>
        </button>
      </div>

      {/* Execution Results Drawer */}
      {executionResult && (
        <div className={`p-6 rounded-2xl border space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-300 ${
          mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
        }`}>
          {/* Header */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 px-3 py-1 rounded-lg bg-emerald-500/15 text-emerald-500 border border-emerald-500/20 font-bold text-xs">
              <CheckCircle className="w-4 h-4" />
              <span>PASSED ({executionResult.testsPassedCount}/{executionResult.totalTestsCount} Tests)</span>
            </div>
            <div className="flex items-center gap-1 text-xs text-slate-400 font-bold">
              <Clock className="w-3.5 h-3.5" />
              <span>{executionResult.executionTimeMs} ms</span>
            </div>
          </div>

          {/* Complexity Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className={`p-4 rounded-xl border ${mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'}`}>
              <div className="flex items-center gap-2 text-xs text-slate-400 font-semibold mb-1">
                <Cpu className="w-4 h-4 text-sky-400" />
                <span>Time Complexity</span>
              </div>
              <span className="font-heading font-extrabold text-lg text-sky-400">{executionResult.timeComplexity}</span>
            </div>

            <div className={`p-4 rounded-xl border ${mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'}`}>
              <div className="flex items-center gap-2 text-xs text-slate-400 font-semibold mb-1">
                <HardDrive className="w-4 h-4 text-amber-400" />
                <span>Space Complexity</span>
              </div>
              <span className="font-heading font-extrabold text-lg text-amber-400">{executionResult.spaceComplexity}</span>
            </div>
          </div>

          {/* AI Code Critique */}
          <div className={`p-4 rounded-xl border flex items-start gap-3 ${
            mode === 'dark' ? 'bg-indigo-500/10 border-indigo-500/20 text-indigo-200' : 'bg-indigo-50 border-indigo-200 text-indigo-900'
          }`}>
            <Lightbulb className="w-5 h-5 text-indigo-400 shrink-0 mt-0.5" />
            <div className="space-y-1 text-xs">
              <span className="font-bold block">💡 AI Code Critique</span>
              <p className="leading-relaxed">{executionResult.codeCritique}</p>
            </div>
          </div>

          {/* Test Cases Output */}
          <div className="space-y-2">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider block">Test Cases Execution Output</span>
            {executionResult.testResults.map((tc: any, i: number) => (
              <div 
                key={i} 
                className={`p-3 rounded-lg border text-xs font-code flex items-center justify-between ${
                  mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'
                }`}
              >
                <div className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-emerald-500" />
                  <span>Input: {tc.input}</span>
                </div>
                <span className="text-emerald-400 font-bold">→ Output: {tc.output}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
