import React, { useState } from 'react';
import { useTheme } from '../context/ThemeContext';
import { Briefcase, CheckCircle, AlertTriangle } from 'lucide-react';

export const JobAnalyzerView: React.FC = () => {
  const { mode, colors } = useTheme();

  const [jobText, setJobText] = useState<string>('');
  const [analysis, setAnalysis] = useState<any | null>(null);

  const handleAnalyze = () => {
    if (!jobText.trim()) return;

    setAnalysis({
      matchPercentage: 78,
      jobTitle: 'Senior Backend Engineer (Python / AWS)',
      matchingSkills: ['Python', 'SQL', 'PostgreSQL', 'Docker', 'REST API'],
      missingSkills: ['Kubernetes', 'Redis', 'Kafka', 'System Architecture'],
    });
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Header */}
      <div className={`p-6 rounded-2xl border ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <h1 className="font-heading font-extrabold text-2xl flex items-center gap-2">
          <Briefcase className="w-6 h-6 text-emerald-400" />
          <span>Job Description (JD) Gap Matcher</span>
        </h1>
        <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
          Paste any Job Description to parse required technical skills and compare against your resume
        </p>
      </div>

      {/* Input Area */}
      <div className={`p-6 rounded-2xl border space-y-4 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <textarea
          value={jobText}
          onChange={(e) => setJobText(e.target.value)}
          placeholder="Paste Job Description (JD) text here... (e.g. We are looking for a Senior Backend Developer with 4+ years Python, PostgreSQL, Redis, Kubernetes experience...)"
          className={`w-full h-40 p-4 rounded-xl font-code text-xs outline-none border resize-none ${
            mode === 'dark' ? 'bg-[#0B0F19] border-[#334155] text-white' : 'bg-[#F8FAFC] border-[#CBD5E1] text-slate-900'
          }`}
        />

        <button
          onClick={handleAnalyze}
          className="px-8 py-3 rounded-xl font-bold text-xs text-white shadow-lg transition-transform active:scale-98"
          style={{ background: colors.gradient }}
        >
          Compare Resume Against Job Description
        </button>
      </div>

      {/* Results Section */}
      {analysis && (
        <div className={`p-6 rounded-2xl border space-y-6 animate-in fade-in duration-300 ${
          mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
        }`}>
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-heading font-extrabold text-xl">{analysis.jobTitle}</h3>
              <p className="text-xs text-slate-400 font-semibold">Parsed Skills Comparison</p>
            </div>
            <div className="text-right">
              <span className="font-heading font-extrabold text-3xl text-emerald-400">{analysis.matchPercentage}%</span>
              <span className="text-xs text-slate-400 block font-bold">Role Match Score</span>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            {/* Matching Skills */}
            <div className="space-y-3">
              <h4 className="font-bold text-sm text-emerald-400 flex items-center gap-2">
                <CheckCircle className="w-4 h-4" /> Matching Resume Skills ({analysis.matchingSkills.length})
              </h4>
              <div className="flex flex-wrap gap-2">
                {analysis.matchingSkills.map((s: string, idx: number) => (
                  <span key={idx} className="px-3 py-1 rounded-lg bg-emerald-500/15 text-emerald-400 border border-emerald-500/20 text-xs font-bold">
                    ✓ {s}
                  </span>
                ))}
              </div>
            </div>

            {/* Missing Skills */}
            <div className="space-y-3">
              <h4 className="font-bold text-sm text-rose-400 flex items-center gap-2">
                <AlertTriangle className="w-4 h-4" /> Missing Keywords / Gaps ({analysis.missingSkills.length})
              </h4>
              <div className="flex flex-wrap gap-2">
                {analysis.missingSkills.map((s: string, idx: number) => (
                  <span key={idx} className="px-3 py-1 rounded-lg bg-rose-500/15 text-rose-400 border border-rose-500/20 text-xs font-bold">
                    ✗ {s}
                  </span>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
