import React, { useState } from 'react';
import { useTheme, THEME_VARIANTS } from '../context/ThemeContext';
import type { ThemeVariant, Language } from '../types';
import { User, Palette, Globe, Shield, Trash2, Check, Moon, Sun, Award } from 'lucide-react';

export const ProfileView: React.FC = () => {
  const { mode, variant, colors, language, targetRole, setMode, setVariant, setLanguage, setTargetRole } = useTheme();

  const [showDeleteModal, setShowDeleteModal] = useState<boolean>(false);

  return (
    <div className="space-y-6 pb-12 max-w-4xl mx-auto">
      {/* User Header */}
      <div className={`p-6 rounded-2xl border flex flex-col sm:flex-row items-center gap-6 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div 
          className="w-20 h-20 rounded-2xl flex items-center justify-center font-extrabold text-2xl text-white shadow-xl"
          style={{ background: colors.gradient }}
        >
          AM
        </div>

        <div className="space-y-1 text-center sm:text-left">
          <h1 className="font-heading font-extrabold text-2xl">Alex Morgan</h1>
          <p className="text-xs text-slate-400 font-semibold">alex.morgan@example.com • PRO Member</p>
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/15 text-emerald-500 font-bold text-xs border border-emerald-500/20 mt-2">
            <Award className="w-3.5 h-3.5" /> Target: {targetRole}
          </div>
        </div>
      </div>

      {/* Target Role Selector */}
      <div className={`p-6 rounded-2xl border space-y-3 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <h2 className="font-heading font-bold text-base flex items-center gap-2">
          <User className="w-5 h-5 text-indigo-400" />
          <span>Target Tech Role</span>
        </h2>
        <select
          value={targetRole}
          onChange={(e) => setTargetRole(e.target.value)}
          className={`w-full p-3 rounded-xl border text-xs font-bold outline-none cursor-pointer ${
            mode === 'dark' ? 'bg-[#0B0F19] border-[#334155] text-white' : 'bg-[#F8FAFC] border-[#CBD5E1] text-slate-900'
          }`}
        >
          <option value="Senior Software Engineer (SDE-2)">Senior Software Engineer (SDE-2)</option>
          <option value="Junior / Entry Level SDE (SDE-1)">Junior / Entry Level SDE (SDE-1)</option>
          <option value="Backend Developer (Python / Node / Java)">Backend Developer (Python / Node / Java)</option>
          <option value="Frontend Engineer (React / Next.js)">Frontend Engineer (React / Next.js)</option>
          <option value="DevOps & Cloud Infrastructure SRE">DevOps & Cloud Infrastructure SRE</option>
          <option value="Machine Learning & AI Engineer">Machine Learning & AI Engineer</option>
        </select>
      </div>

      {/* Theme Customization Engine (6 Theme Accent Variants + Light/Dark Canvas) */}
      <div className={`p-6 rounded-2xl border space-y-6 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <div className="flex items-center justify-between">
          <h2 className="font-heading font-bold text-base flex items-center gap-2">
            <Palette className="w-5 h-5 text-purple-400" />
            <span>Theme Customization Engine</span>
          </h2>
          
          <button
            onClick={() => setMode(mode === 'dark' ? 'light' : 'dark')}
            className={`px-3 py-1.5 rounded-lg border text-xs font-bold flex items-center gap-2 ${
              mode === 'dark' ? 'bg-[#0B0F19] border-[#334155] text-amber-400' : 'bg-[#F8FAFC] border-[#CBD5E1] text-indigo-600'
            }`}
          >
            {mode === 'dark' ? <Sun className="w-4 h-4" /> : <Moon className="w-4 h-4" />}
            <span>Mode: {mode === 'dark' ? 'Dark Canvas' : 'Light Canvas'}</span>
          </button>
        </div>

        {/* 6 Accent Theme Variants Showcase */}
        <div className="space-y-2">
          <span className="text-xs font-bold text-slate-400 block uppercase tracking-wider">Select Brand Accent Variant</span>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
            {Object.keys(THEME_VARIANTS).map((vKey) => {
              const vColors = THEME_VARIANTS[vKey as ThemeVariant];
              const isSelected = variant === vKey;

              return (
                <div
                  key={vKey}
                  onClick={() => setVariant(vKey as ThemeVariant)}
                  className={`p-3 rounded-xl border cursor-pointer transition-all flex items-center justify-between ${
                    isSelected
                      ? 'border-indigo-500 shadow-md ring-2 ring-indigo-500/30'
                      : mode === 'dark'
                      ? 'bg-[#0B0F19] border-[#1E293B] hover:border-slate-700'
                      : 'bg-[#F8FAFC] border-[#E2E8F0] hover:border-slate-300'
                  }`}
                >
                  <div className="flex items-center gap-2.5">
                    <span 
                      className="w-5 h-5 rounded-full inline-block shadow"
                      style={{ backgroundColor: vColors.primary }}
                    />
                    <span className="text-xs font-bold capitalize">{vColors.name}</span>
                  </div>

                  {isSelected && <Check className="w-4 h-4 text-emerald-500" />}
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Language Preferences */}
      <div className={`p-6 rounded-2xl border space-y-3 ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <h2 className="font-heading font-bold text-base flex items-center gap-2">
          <Globe className="w-5 h-5 text-sky-400" />
          <span>Language Preferences</span>
        </h2>
        <select
          value={language}
          onChange={(e) => setLanguage(e.target.value as Language)}
          className={`w-full p-3 rounded-xl border text-xs font-bold outline-none cursor-pointer ${
            mode === 'dark' ? 'bg-[#0B0F19] border-[#334155] text-white' : 'bg-[#F8FAFC] border-[#CBD5E1] text-slate-900'
          }`}
        >
          <option value="en">English (US / UK)</option>
          <option value="hi">Hindi (हिंदी)</option>
          <option value="es">Spanish (Español)</option>
          <option value="fr">French (Français)</option>
          <option value="de">German (Deutsch)</option>
        </select>
      </div>

      {/* Danger Zone */}
      <div className="p-6 rounded-2xl border border-rose-500/30 bg-rose-500/5 space-y-3">
        <h2 className="font-heading font-bold text-base text-rose-500 flex items-center gap-2">
          <Shield className="w-5 h-5" />
          <span>Privacy & Account Management</span>
        </h2>
        <p className="text-xs text-slate-400">Permanently delete account data and GDPR telemetry history.</p>
        <button
          onClick={() => setShowDeleteModal(true)}
          className="px-4 py-2 rounded-xl bg-rose-500 text-white font-bold text-xs hover:bg-rose-600 transition-all flex items-center gap-2"
        >
          <Trash2 className="w-4 h-4" /> Request Account Deletion
        </button>
      </div>

      {/* GDPR Deletion Modal */}
      {showDeleteModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
          <div className={`p-6 rounded-2xl border max-w-md w-full space-y-4 ${
            mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
          }`}>
            <h3 className="font-heading font-bold text-lg text-rose-500">Confirm Account Deletion</h3>
            <p className="text-xs text-slate-400 leading-relaxed">
              Are you sure you want to request permanent account deletion? All saved code solutions, resume analysis risk maps, and practice history will be permanently deleted.
            </p>
            <div className="flex justify-end gap-3 pt-2">
              <button
                onClick={() => setShowDeleteModal(false)}
                className="px-4 py-2 rounded-xl text-xs font-bold border border-slate-500/30"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  alert('Account deletion request submitted!');
                  setShowDeleteModal(false);
                }}
                className="px-4 py-2 rounded-xl text-xs font-bold bg-rose-500 text-white"
              >
                Permanently Delete Account
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
