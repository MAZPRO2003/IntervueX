import React from 'react';
import { useTheme } from '../context/ThemeContext';
import { MOCK_COMPANIES } from '../mockData';
import { Building2, Search, MapPin, Briefcase, ArrowRight, CheckCircle2 } from 'lucide-react';

export const CompaniesView: React.FC = () => {
  const { mode, colors } = useTheme();

  return (
    <div className="space-y-6 pb-12">
      {/* Header */}
      <div className={`p-6 rounded-2xl border flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div>
          <h1 className="font-heading font-extrabold text-2xl flex items-center gap-2">
            <Building2 className="w-6 h-6 text-sky-400" />
            <span>Target Company Directory & Role Tracks</span>
          </h1>
          <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
            Explore interview loops, sample questions, and role tracks for top tech companies
          </p>
        </div>

        {/* Search Bar */}
        <div className={`flex items-center gap-2 px-3 py-2 rounded-xl border text-xs w-full sm:w-64 ${
          mode === 'dark' ? 'bg-[#0B0F19] border-[#1E293B]' : 'bg-[#F8FAFC] border-[#CBD5E1]'
        }`}>
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search company (Google, Stripe...)"
            className="bg-transparent border-none outline-none w-full"
          />
        </div>
      </div>

      {/* Grid of Companies */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {MOCK_COMPANIES.map((comp) => (
          <div
            key={comp.id}
            className={`p-6 rounded-2xl border space-y-4 flex flex-col justify-between transition-all hover:-translate-y-1 shadow-lg ${
              mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
            }`}
          >
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-3xl">{comp.logoUrl}</span>
                <span className="text-xs font-bold px-2.5 py-0.5 rounded bg-amber-500/15 text-amber-500 border border-amber-500/20">
                  {comp.difficulty}
                </span>
              </div>

              <div>
                <h3 className="font-heading font-extrabold text-xl">{comp.name}</h3>
                <span className="text-xs text-slate-400 font-semibold">{comp.category}</span>
              </div>

              <div className="flex items-center gap-3 text-xs text-slate-400 font-medium">
                <span className="flex items-center gap-1">
                  <MapPin className="w-3.5 h-3.5 text-slate-500" /> {comp.location}
                </span>
                <span className="flex items-center gap-1">
                  <Briefcase className="w-3.5 h-3.5 text-slate-500" /> {comp.activeRoles} Roles
                </span>
              </div>

              {/* Interview Stages */}
              <div className="space-y-1.5 pt-2">
                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Interview Stages</span>
                {comp.stages.map((stage, i) => (
                  <div key={i} className="flex items-center gap-2 text-xs">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500 shrink-0" />
                    <span className="text-slate-300 font-medium">{stage}</span>
                  </div>
                ))}
              </div>
            </div>

            <button
              className="w-full mt-4 py-2.5 rounded-xl font-bold text-xs text-white shadow-md transition-transform active:scale-98 flex items-center justify-center gap-2"
              style={{ background: colors.gradient }}
            >
              <span>Practice {comp.name} Track</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};
