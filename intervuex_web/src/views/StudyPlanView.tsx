import React from 'react';
import { useTheme } from '../context/ThemeContext';
import { Compass, Flame, CheckCircle2, Circle } from 'lucide-react';

export const StudyPlanView: React.FC = () => {
  const { mode } = useTheme();

  return (
    <div className="space-y-6 pb-12">
      {/* Header Banner */}
      <div className={`p-6 rounded-2xl border flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div>
          <h1 className="font-heading font-extrabold text-2xl flex items-center gap-2">
            <Compass className="w-6 h-6 text-emerald-400" />
            <span>Personalized Study Plan & Streak Roadmap</span>
          </h1>
          <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
            Track your daily interview preparation targets and streak consistency
          </p>
        </div>

        <div className="flex items-center gap-2 px-4 py-2 rounded-xl bg-amber-500/15 text-amber-400 border border-amber-500/20 font-bold text-xs">
          <Flame className="w-4 h-4 fill-amber-500 animate-bounce" />
          <span>7 Day Practice Streak Active!</span>
        </div>
      </div>

      {/* Daily Checklist */}
      <div className={`p-6 rounded-2xl border space-y-4 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <h2 className="font-heading font-bold text-lg">Today's Practice Checklist</h2>
        <div className="space-y-3">
          {[
            { text: 'Solve 1 Medium Graph DFS Problem in Code Sandbox', done: true },
            { text: 'Review 5 System Design Flashcards', done: true },
            { text: 'Complete 1-Tap AI Bullet Rewrite for Resume', done: true },
            { text: 'Practice 1 Voice AI Mock Interview Session', done: false },
          ].map((item, idx) => (
            <div
              key={idx}
              className={`p-4 rounded-xl border flex items-center gap-3 text-xs font-semibold ${
                mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#E2E8F0]'
              }`}
            >
              {item.done ? (
                <CheckCircle2 className="w-5 h-5 text-emerald-500 shrink-0" />
              ) : (
                <Circle className="w-5 h-5 text-slate-500 shrink-0" />
              )}
              <span className={item.done ? 'line-through text-slate-400' : ''}>{item.text}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
