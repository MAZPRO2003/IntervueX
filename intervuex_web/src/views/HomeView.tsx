import React from 'react';
import { useTheme } from '../context/ThemeContext';
import { MOCK_QUESTIONS } from '../mockData';
import { 
  Sparkles, 
  Code2, 
  FileText, 
  Bot, 
  ArrowRight, 
  Building2, 
  TrendingUp,
  Award
} from 'lucide-react';

interface HomeViewProps {
  onNavigate: (tab: string) => void;
  onSelectQuestion: (q: any) => void;
}

export const HomeView: React.FC<HomeViewProps> = ({ onNavigate, onSelectQuestion }) => {
  const { mode, colors, targetRole } = useTheme();

  return (
    <div className="space-y-8 pb-12">
      {/* Hero Card */}
      <div 
        className="rounded-3xl p-8 relative overflow-hidden shadow-2xl border border-white/10"
        style={{ background: colors.gradient }}
      >
        <div className="relative z-10 max-w-3xl space-y-4 text-white">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/15 text-xs font-bold backdrop-blur-md border border-white/20">
            <Sparkles className="w-3.5 h-3.5" />
            <span>AI-POWERED INTERVIEW SUITE</span>
          </div>

          <h1 className="font-heading text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight leading-tight">
            Master Technical Interviews for <br className="hidden sm:inline" />
            <span className="text-amber-300">{targetRole}</span>
          </h1>

          <p className="text-white/80 text-sm sm:text-base font-medium max-w-2xl">
            Real-time IDE code sandbox, AI resume risk overlays, multi-framework bullet rewriter, and interactive voice mock interviewers tailored to your target company.
          </p>

          <div className="flex flex-wrap items-center gap-4 pt-2">
            <button
              onClick={() => onNavigate('sandbox')}
              className="px-6 py-3 rounded-xl bg-white text-slate-900 font-bold text-sm shadow-xl hover:bg-slate-100 transition-all flex items-center gap-2"
            >
              <Code2 className="w-4 h-4 text-indigo-600" />
              <span>Launch Code Sandbox</span>
              <ArrowRight className="w-4 h-4" />
            </button>
            <button
              onClick={() => onNavigate('resume')}
              className="px-6 py-3 rounded-xl bg-black/20 text-white font-bold text-sm backdrop-blur-md border border-white/20 hover:bg-black/30 transition-all flex items-center gap-2"
            >
              <FileText className="w-4 h-4" />
              <span>Scan Resume Risks</span>
            </button>
          </div>
        </div>

        {/* Decorative Circles */}
        <div className="absolute -right-16 -bottom-16 w-80 h-80 rounded-full bg-white/10 blur-2xl pointer-events-none" />
      </div>

      {/* Quick Access Action Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { title: 'Live Code Sandbox', sub: 'Interactive IDE & AI Critique', icon: Code2, tab: 'sandbox', color: 'text-sky-500' },
          { title: 'Resume Risk Map', sub: 'PDF Highlight & STAR Defense', icon: FileText, tab: 'resume', color: 'text-emerald-500' },
          { title: 'AI Mock Interview', sub: 'Voice & Speech Feedback', icon: Bot, tab: 'mock', color: 'text-purple-500' },
          { title: 'Company Tracks', sub: 'FAANG & Top Tech Guides', icon: Building2, tab: 'companies', color: 'text-amber-500' },
        ].map((item, idx) => {
          const Icon = item.icon;
          return (
            <div
              key={idx}
              onClick={() => onNavigate(item.tab)}
              className={`p-5 rounded-2xl border transition-all cursor-pointer hover:-translate-y-1 shadow-lg ${
                mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B] hover:border-slate-700' : 'bg-white border-[#E2E8F0] hover:border-slate-300'
              }`}
            >
              <div className="flex items-center justify-between mb-3">
                <div className={`p-3 rounded-xl bg-slate-500/10 ${item.color}`}>
                  <Icon className="w-6 h-6" />
                </div>
                <ArrowRight className="w-4 h-4 opacity-40 group-hover:opacity-100" />
              </div>
              <h3 className="font-bold text-base mb-1">{item.title}</h3>
              <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>{item.sub}</p>
            </div>
          );
        })}
      </div>

      {/* Two Column Layout: Resume Readiness Gauge & Practice Queue */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        {/* Left Column: Resume Readiness */}
        <div className={`p-6 rounded-2xl border ${
          mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
        }`}>
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-heading font-bold text-lg flex items-center gap-2">
              <Award className="w-5 h-5" style={{ color: colors.primary }} />
              <span>Resume Readiness Score</span>
            </h2>
            <span className="text-xs font-bold px-2.5 py-1 rounded-md bg-emerald-500/15 text-emerald-500 border border-emerald-500/20">
              OPTIMIZED
            </span>
          </div>

          <div className="flex items-center justify-center my-6">
            <div className="relative w-36 h-36 rounded-full flex items-center justify-center border-8 border-emerald-500/20 shadow-inner">
              <div 
                className="absolute inset-0 rounded-full border-8 border-emerald-500 border-t-transparent animate-spin-slow"
                style={{ clipPath: 'polygon(0 0, 100% 0, 100% 85%, 0 85%)' }}
              />
              <div className="text-center">
                <span className="font-heading text-4xl font-extrabold">85</span>
                <span className="text-xs text-slate-400 font-bold block">/ 100 Quality</span>
              </div>
            </div>
          </div>

          <div className="space-y-3 text-xs">
            <div className="flex justify-between items-center py-1 border-b border-slate-500/10">
              <span className="text-slate-400">ATS Compatibility</span>
              <span className="font-bold text-emerald-500">92% Match</span>
            </div>
            <div className="flex justify-between items-center py-1 border-b border-slate-500/10">
              <span className="text-slate-400">Quantified Impact Metrics</span>
              <span className="font-bold text-emerald-500">88% Present</span>
            </div>
            <div className="flex justify-between items-center py-1 border-b border-slate-500/10">
              <span className="text-slate-400">Flagged Unsupported Claims</span>
              <span className="font-bold text-amber-500">2 Warnings</span>
            </div>
          </div>

          <button
            onClick={() => onNavigate('resume')}
            className="w-full mt-5 py-2.5 rounded-xl font-bold text-xs text-white shadow-md transition-transform active:scale-98"
            style={{ background: colors.gradient }}
          >
            Open Interactive Risk Map
          </button>
        </div>

        {/* Right Column: Daily Recommended Practice Queue */}
        <div className={`lg:col-span-2 p-6 rounded-2xl border space-y-4 ${
          mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
        }`}>
          <div className="flex items-center justify-between">
            <div>
              <h2 className="font-heading font-bold text-lg flex items-center gap-2">
                <TrendingUp className="w-5 h-5" style={{ color: colors.primary }} />
                <span>Daily Practice Problem Queue</span>
              </h2>
              <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
                Recommended based on your target role: {targetRole}
              </p>
            </div>
            <button 
              onClick={() => onNavigate('questions')}
              className="text-xs font-bold hover:underline"
              style={{ color: colors.primary }}
            >
              View All Questions
            </button>
          </div>

          <div className="space-y-3">
            {MOCK_QUESTIONS.map((q) => (
              <div
                key={q.id}
                className={`p-4 rounded-xl border flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 transition-all hover:border-slate-500/40 ${
                  mode === 'dark' ? 'bg-[#0B0F19]/60 border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'
                }`}
              >
                <div className="space-y-1">
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
                  </div>
                  <h4 className="font-bold text-sm">{q.title}</h4>
                  <div className="flex flex-wrap gap-1">
                    {q.topics.map((t, i) => (
                      <span key={i} className="text-[10px] font-medium text-slate-400 bg-slate-500/10 px-1.5 py-0.5 rounded">
                        {t}
                      </span>
                    ))}
                  </div>
                </div>

                <button
                  onClick={() => {
                    onSelectQuestion(q);
                    onNavigate('sandbox');
                  }}
                  className="px-4 py-2 rounded-lg text-xs font-bold text-white shadow-md whitespace-nowrap"
                  style={{ backgroundColor: colors.primary }}
                >
                  Solve in IDE
                </button>
              </div>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
};
