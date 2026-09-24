import React, { useState } from 'react';
import { useTheme } from '../context/ThemeContext';
import { MOCK_RISKS, MOCK_REWRITES, MOCK_PDF_HIGHLIGHTS, MOCK_RESUME_QUESTIONS } from '../mockData';
import { 
  Upload, 
  Sparkles, 
  Copy, 
  Eye, 
  ShieldAlert, 
  HelpCircle,
  TrendingUp,
  Award
} from 'lucide-react';

export const ResumeAnalyzerView: React.FC = () => {
  const { mode, colors } = useTheme();

  const [activeFramework, setActiveFramework] = useState<'STAR' | 'GOOGLE_XYZ' | 'ACTION_IMPACT'>('STAR');
  const [selectedHighlight, setSelectedHighlight] = useState<any | null>(MOCK_PDF_HIGHLIGHTS[0]);

  return (
    <div className="space-y-8 pb-12">
      {/* Upload Banner */}
      <div className={`p-8 rounded-3xl border text-center space-y-4 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div className="w-16 h-16 rounded-2xl mx-auto flex items-center justify-center text-white shadow-xl" style={{ background: colors.gradient }}>
          <Upload className="w-8 h-8" />
        </div>
        <h1 className="font-heading font-extrabold text-2xl sm:text-3xl">AI Resume Risk Analyzer & PDF Risk Map</h1>
        <p className={`text-xs sm:text-sm max-w-2xl mx-auto ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
          Upload your resume (PDF/DOCX) or paste text. Our AI scans for unsupported skill claims, missing metrics, and provides STAR defenses, 1-Tap AI rewrites, and PDF coordinate risk overlays.
        </p>
        <div className="flex flex-wrap justify-center gap-4 pt-2">
          <label className="px-6 py-3 rounded-xl font-bold text-xs text-white shadow-lg cursor-pointer transition-transform hover:scale-105" style={{ background: colors.gradient }}>
            <span>Choose PDF / DOCX Resume</span>
            <input type="file" className="hidden" accept=".pdf,.docx" />
          </label>
        </div>
      </div>

      {/* Multi-Factor Quality Score Breakdown */}
      <div className={`p-6 rounded-2xl border space-y-6 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div className="flex items-center justify-between">
          <div>
            <h2 className="font-heading font-bold text-lg flex items-center gap-2">
              <Award className="w-5 h-5 text-emerald-500" />
              <span>Multi-Factor Quality Score Breakdown</span>
            </h2>
            <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
              Scored across 10 core resume engineering factors
            </p>
          </div>
          <span className="text-xl font-heading font-extrabold text-emerald-500">85 / 100</span>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-5 gap-3">
          {[
            { label: 'ATS Compatibility', val: 92 },
            { label: 'Content Quality', val: 84 },
            { label: 'Structure & Flow', val: 88 },
            { label: 'Skills Alignment', val: 90 },
            { label: 'Experience Depth', val: 82 },
            { label: 'Projects Evidence', val: 78 },
            { label: 'Job Relevance', val: 86 },
            { label: 'Readability Index', val: 94 },
            { label: 'Formatting Standard', val: 85 },
            { label: 'Quantified Impact', val: 75 },
          ].map((item, idx) => (
            <div key={idx} className={`p-3 rounded-xl border text-center ${
              mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'
            }`}>
              <span className="text-[10px] font-bold text-slate-400 block mb-1">{item.label}</span>
              <span className="font-heading font-extrabold text-sm text-emerald-400">{item.val}%</span>
            </div>
          ))}
        </div>
      </div>

      {/* Two Column Layout: Traceable Risks & Interactive PDF Risk Overlay Map */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">

        {/* Traceable Risks & Exaggeration Detector */}
        <div className={`p-6 rounded-2xl border space-y-4 ${
          mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
        }`}>
          <div className="flex items-center justify-between">
            <h2 className="font-heading font-bold text-lg flex items-center gap-2">
              <ShieldAlert className="w-5 h-5 text-amber-500" />
              <span>Traceable Risk & Exaggeration Detector</span>
            </h2>
            <span className="text-xs font-bold px-2 py-0.5 rounded bg-amber-500/15 text-amber-500">
              {MOCK_RISKS.length} Risks Flagged
            </span>
          </div>

          <div className="space-y-4">
            {MOCK_RISKS.map((risk) => (
              <div 
                key={risk.id}
                className={`p-4 rounded-xl border space-y-3 ${
                  mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'
                }`}
              >
                <div className="flex items-center justify-between">
                  <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                    risk.riskLevel === 'High' ? 'bg-rose-500/15 text-rose-500' : 'bg-amber-500/15 text-amber-500'
                  }`}>
                    {risk.riskLevel} Risk Warning
                  </span>
                  <span className="text-xs text-slate-400 font-semibold">{risk.evidenceSource}</span>
                </div>

                <h4 className="font-bold text-sm">{risk.title}</h4>
                <p className="text-xs text-slate-400 leading-relaxed">{risk.whyQuestioned}</p>

                {/* STAR Defense Box */}
                <div className="p-3 rounded-lg bg-indigo-500/10 border border-indigo-500/20 space-y-1.5 text-xs text-indigo-300">
                  <span className="font-bold block text-indigo-400">🛡️ STAR Defense Strategy:</span>
                  <p><strong>Situation:</strong> {risk.starDefense.situation}</p>
                  <p><strong>Action:</strong> {risk.starDefense.action}</p>
                  <p><strong>Result:</strong> {risk.starDefense.result}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Interactive PDF Risk Map Overlay Component */}
        <div className={`p-6 rounded-2xl border space-y-4 ${
          mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
        }`}>
          <div className="flex items-center justify-between">
            <h2 className="font-heading font-bold text-lg flex items-center gap-2">
              <Eye className="w-5 h-5 text-sky-500" />
              <span>Interactive PDF Risk Map Overlay</span>
            </h2>
            <span className="text-xs text-slate-400 font-bold">Page 1 of 1</span>
          </div>

          {/* Visual PDF Page Canvas Surface */}
          <div className={`relative w-full h-[420px] rounded-xl border overflow-hidden p-6 font-code text-xs space-y-4 ${
            mode === 'dark' ? 'bg-[#0B0F19] border-[#30363D] text-slate-300' : 'bg-white border-[#CBD5E1] text-slate-800'
          }`}>
            {/* Mock PDF Document Content */}
            <div className="font-bold text-base text-center border-b pb-2">ALEX MORGAN - SENIOR SOFTWARE ENGINEER</div>
            <p className="text-slate-400">Email: alex@example.com | GitHub: github.com/alexm</p>
            <div className="font-bold border-b pb-1 mt-4">TECHNICAL SKILLS</div>
            <p>Languages: Python, JavaScript, Java, SQL, HTML/CSS</p>
            <p className="bg-rose-500/20 p-1 rounded border border-rose-500/40">
              Cloud & DevOps: Kubernetes, Docker, AWS, FastAPI, Git
            </p>

            <div className="font-bold border-b pb-1 mt-4">PROJECT EXPERIENCE</div>
            <p className="font-semibold">Primary E-Commerce Microservice Architecture</p>
            <p className="bg-amber-500/20 p-1 rounded border border-amber-500/40">
              Built microservice backend utilizing FastAPI, Docker, and PostgreSQL.
            </p>

            {/* Render Absolute Bounding Boxes Overlay */}
            {MOCK_PDF_HIGHLIGHTS.map((hl) => (
              <div
                key={hl.id}
                onClick={() => setSelectedHighlight(hl)}
                className={`absolute cursor-pointer border-2 rounded transition-all hover:scale-101 flex items-center justify-end pr-2 ${
                  hl.severity === 'high_warning' 
                    ? 'border-rose-500 bg-rose-500/15 text-rose-400 font-bold'
                    : 'border-amber-500 bg-amber-500/15 text-amber-400 font-bold'
                }`}
                style={{
                  left: `${hl.xPercent}%`,
                  top: `${hl.yPercent}%`,
                  width: `${hl.widthPercent}%`,
                  height: `${hl.heightPercent}%`,
                }}
              >
                <span className="text-[10px] bg-black/60 px-1.5 py-0.5 rounded">⚠️ Flagged</span>
              </div>
            ))}
          </div>

          {/* Selected Highlight Detail Card */}
          {selectedHighlight && (
            <div className={`p-4 rounded-xl border space-y-2 text-xs ${
              mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'
            }`}>
              <div className="flex items-center justify-between">
                <span className="font-bold text-rose-400">{selectedHighlight.flagCategory}</span>
                <span className="text-slate-400">Page {selectedHighlight.page}</span>
              </div>
              <p className="text-slate-300 font-code">"{selectedHighlight.claimText}"</p>
              <p className="text-amber-400"><strong>Interviewer Probe:</strong> {selectedHighlight.interviewerProbe}</p>
            </div>
          )}
        </div>

      </div>

      {/* 1-Tap AI Bullet Rewriter (Multi-Framework Support) */}
      <div className={`p-6 rounded-2xl border space-y-6 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div>
            <h2 className="font-heading font-bold text-lg flex items-center gap-2">
              <Sparkles className="w-5 h-5 text-indigo-400" />
              <span>1-Tap AI Bullet Rewriter</span>
            </h2>
            <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
              Select your preferred resume rewriting framework below
            </p>
          </div>

          {/* Multi-Framework Filter Chips */}
          <div className="flex items-center gap-2">
            {[
              { id: 'STAR', label: '⭐ STAR Method' },
              { id: 'GOOGLE_XYZ', label: '🎯 Google XYZ Formula' },
              { id: 'ACTION_IMPACT', label: '⚡ Action + Impact' },
            ].map((fw) => (
              <button
                key={fw.id}
                onClick={() => setActiveFramework(fw.id as any)}
                className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                  activeFramework === fw.id
                    ? 'text-white shadow-md'
                    : mode === 'dark'
                    ? 'bg-[#0B0F19] text-slate-400 hover:text-white'
                    : 'bg-[#F1F5F9] text-slate-600 hover:text-slate-900'
                }`}
                style={activeFramework === fw.id ? { background: colors.gradient } : {}}
              >
                {fw.label}
              </button>
            ))}
          </div>
        </div>

        {/* Rewritten Bullet Cards */}
        <div className="space-y-4">
          {MOCK_REWRITES.map((rw, idx) => {
            let rewrittenText = rw.starBullet;
            let badgeLabel = 'AFTER (STAR METHOD)';

            if (activeFramework === 'GOOGLE_XYZ') {
              rewrittenText = rw.googleXyzBullet;
              badgeLabel = 'AFTER (GOOGLE XYZ FORMULA)';
            } else if (activeFramework === 'ACTION_IMPACT') {
              rewrittenText = rw.actionImpactBullet;
              badgeLabel = 'AFTER (ACTION + IMPACT)';
            }

            return (
              <div 
                key={idx}
                className={`p-4 rounded-xl border space-y-3 ${
                  mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'
                }`}
              >
                {/* Before */}
                <div className="flex items-start gap-3 text-xs">
                  <span className="px-2 py-0.5 rounded bg-rose-500/15 text-rose-500 font-bold shrink-0">BEFORE</span>
                  <span className="text-slate-400 italic">"{rw.originalBullet}"</span>
                </div>

                {/* After */}
                <div className="flex items-start gap-3 text-xs border-t border-slate-500/10 pt-3">
                  <span className="px-2 py-0.5 rounded bg-emerald-500/15 text-emerald-500 font-bold shrink-0">{badgeLabel}</span>
                  <span className="font-bold text-emerald-400">{rewrittenText}</span>
                </div>

                {/* Impact Metric & Copy */}
                <div className="flex items-center justify-between pt-2 text-xs">
                  <div className="flex items-center gap-1.5 text-emerald-400 font-bold">
                    <TrendingUp className="w-3.5 h-3.5" />
                    <span>Impact: {rw.quantifiedImpact}</span>
                  </div>
                  <button
                    onClick={() => {
                      navigator.clipboard.writeText(rewrittenText);
                      alert(`${activeFramework} Bullet copied to clipboard!`);
                    }}
                    className="flex items-center gap-1 px-3 py-1 rounded bg-slate-500/10 hover:bg-slate-500/20 text-xs font-bold"
                  >
                    <Copy className="w-3 h-3" /> Copy ({activeFramework})
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* 50 Tailored Resume Interview Questions */}
      <div className={`p-6 rounded-2xl border space-y-4 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div className="flex items-center justify-between">
          <h2 className="font-heading font-bold text-lg flex items-center gap-2">
            <HelpCircle className="w-5 h-5 text-amber-500" />
            <span>50 Tailored Resume Interview Questions</span>
          </h2>
          <span className="text-xs font-bold text-slate-400">50 Questions Generated</span>
        </div>

        <div className="space-y-4">
          {MOCK_RESUME_QUESTIONS.map((q) => (
            <div key={q.id} className={`p-4 rounded-xl border space-y-2 ${
              mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'
            }`}>
              <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-purple-500/15 text-purple-400">
                {q.category}
              </span>
              <h4 className="font-bold text-sm">{q.question}</h4>
              <p className="text-xs text-slate-400"><strong>Why Asked:</strong> {q.whyAsked}</p>
              <div className="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20 text-xs text-emerald-300">
                <strong>Model Answer:</strong> {q.modelAnswer}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
