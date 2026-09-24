import React from 'react';
import { useTheme } from '../context/ThemeContext';
import { Package, ArrowRight } from 'lucide-react';

export const PacksView: React.FC = () => {
  const { mode, colors } = useTheme();

  const packs = [
    { title: 'FAANG Heavyweight Pack', questions: 45, topic: 'Algorithms & Dynamic Programming', progress: 65, color: 'from-purple-600 to-indigo-600' },
    { title: 'System Design Mastery Pack', questions: 25, topic: 'Distributed Architecture & Caching', progress: 40, color: 'from-sky-600 to-blue-600' },
    { title: 'SQL & Database Grilling', questions: 30, topic: 'PostgreSQL, Indexing, Window Functions', progress: 90, color: 'from-emerald-600 to-teal-600' },
    { title: 'Senior Lead Architecture', questions: 20, topic: 'Microservices & High Throughput', progress: 20, color: 'from-amber-600 to-orange-600' },
  ];

  return (
    <div className="space-y-6 pb-12">
      {/* Header */}
      <div className={`p-6 rounded-2xl border ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <h1 className="font-heading font-extrabold text-2xl flex items-center gap-2">
          <Package className="w-6 h-6 text-purple-400" />
          <span>Curated Technical Interview Prep Packs</span>
        </h1>
        <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
          Structured, high-yield company and topic interview preparation roadmaps
        </p>
      </div>

      {/* Grid of Packs */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {packs.map((pack, idx) => (
          <div
            key={idx}
            className={`p-6 rounded-2xl border space-y-4 flex flex-col justify-between shadow-xl ${
              mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
            }`}
          >
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold px-3 py-1 rounded-md bg-white/10 text-slate-300 border border-white/10">
                  {pack.questions} Target Questions
                </span>
                <span className="text-xs font-bold text-emerald-400">{pack.progress}% Complete</span>
              </div>

              <h3 className="font-heading font-extrabold text-xl">{pack.title}</h3>
              <p className="text-xs text-slate-400 font-semibold">{pack.topic}</p>

              {/* Progress Bar */}
              <div className="w-full h-2 rounded-full bg-slate-500/20 overflow-hidden">
                <div className="h-full rounded-full bg-emerald-500" style={{ width: `${pack.progress}%` }} />
              </div>
            </div>

            <button
              className="w-full py-2.5 rounded-xl font-bold text-xs text-white shadow-md flex items-center justify-center gap-2"
              style={{ background: colors.gradient }}
            >
              <span>Continue Pack Roadmaps</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};
