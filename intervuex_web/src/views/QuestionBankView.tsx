import React, { useState } from 'react';
import { useTheme } from '../context/ThemeContext';
import { MOCK_QUESTIONS } from '../mockData';
import { HelpCircle, Search, Code2 } from 'lucide-react';

interface QuestionBankViewProps {
  onSelectQuestion: (q: any) => void;
  onNavigate: (tab: string) => void;
}

export const QuestionBankView: React.FC<QuestionBankViewProps> = ({ onSelectQuestion, onNavigate }) => {
  const { mode, colors } = useTheme();

  const [filterDifficulty, setFilterDifficulty] = useState<string>('All');
  const [filterSource, setFilterSource] = useState<string>('All');
  const [search, setSearch] = useState<string>('');

  const filtered = MOCK_QUESTIONS.filter((q) => {
    if (filterDifficulty !== 'All' && q.difficulty !== filterDifficulty) return false;
    if (filterSource !== 'All' && q.source !== filterSource) return false;
    if (search && !q.title.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });

  return (
    <div className="space-y-6 pb-12">
      {/* Header */}
      <div className={`p-6 rounded-2xl border flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div>
          <h1 className="font-heading font-extrabold text-2xl flex items-center gap-2">
            <HelpCircle className="w-6 h-6 text-indigo-400" />
            <span>Technical Question Bank & LeetCode Practice</span>
          </h1>
          <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
            Explore company-tagged interview questions with instant 1-click IDE sandbox solving
          </p>
        </div>
      </div>

      {/* Filters & Search */}
      <div className={`p-4 rounded-2xl border flex flex-wrap items-center justify-between gap-4 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div className="flex items-center gap-2 px-3 py-2 rounded-xl border text-xs flex-1 min-w-[200px] ${
          mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#CBD5E1]'
        }">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search questions by title or topic..."
            className="bg-transparent border-none outline-none w-full"
          />
        </div>

        <div className="flex items-center gap-3">
          <select
            value={filterDifficulty}
            onChange={(e) => setFilterDifficulty(e.target.value)}
            className={`px-3 py-2 rounded-xl border text-xs font-bold outline-none cursor-pointer ${
              mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B] text-white' : 'bg-white border-[#CBD5E1] text-slate-900'
            }`}
          >
            <option value="All">Difficulty: All</option>
            <option value="Easy">Easy</option>
            <option value="Medium">Medium</option>
            <option value="Hard">Hard</option>
          </select>

          <select
            value={filterSource}
            onChange={(e) => setFilterSource(e.target.value)}
            className={`px-3 py-2 rounded-xl border text-xs font-bold outline-none cursor-pointer ${
              mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B] text-white' : 'bg-white border-[#CBD5E1] text-slate-900'
            }`}
          >
            <option value="All">Source: All</option>
            <option value="Question Bank">Question Bank</option>
            <option value="LeetCode">LeetCode</option>
          </select>
        </div>
      </div>

      {/* Questions List */}
      <div className="space-y-3">
        {filtered.map((q) => (
          <div
            key={q.id}
            className={`p-5 rounded-2xl border flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 transition-all hover:border-slate-500/40 ${
              mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
            }`}
          >
            <div className="space-y-1.5">
              <div className="flex items-center gap-2">
                <span className={`text-[10px] font-extrabold px-2 py-0.5 rounded ${
                  q.difficulty === 'Easy' 
                    ? 'bg-emerald-500/15 text-emerald-500'
                    : q.difficulty === 'Hard'
                    ? 'bg-rose-500/15 text-rose-500'
                    : 'bg-amber-500/15 text-amber-500'
                }`}>
                  {q.difficulty}
                </span>
                <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-sky-500/15 text-sky-500">
                  {q.source}
                </span>
                <span className="text-xs text-slate-400 font-semibold">{q.category}</span>
                {q.company && (
                  <span className="text-xs text-purple-400 font-bold ml-2">🏢 {q.company}</span>
                )}
              </div>

              <h3 className="font-heading font-extrabold text-base">{q.title}</h3>
              <p className="text-xs text-slate-400 line-clamp-1 max-w-3xl">{q.description}</p>
            </div>

            <button
              onClick={() => {
                onSelectQuestion(q);
                onNavigate('sandbox');
              }}
              className="px-5 py-2.5 rounded-xl font-bold text-xs text-white shadow-md whitespace-nowrap flex items-center gap-2"
              style={{ background: colors.gradient }}
            >
              <Code2 className="w-4 h-4" />
              <span>Solve in Sandbox</span>
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};
