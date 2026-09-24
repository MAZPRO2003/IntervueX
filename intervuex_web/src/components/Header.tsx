import React from 'react';
import { useTheme, THEME_VARIANTS } from '../context/ThemeContext';
import type { ThemeVariant, Language } from '../types';
import { 
  Code2, 
  FileText, 
  Bot, 
  Building2, 
  Briefcase, 
  Package, 
  HelpCircle, 
  Layers, 
  Compass, 
  User, 
  Sun, 
  Moon, 
  Globe, 
  Flame,
  Sparkles
} from 'lucide-react';

interface HeaderProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

export const Header: React.FC<HeaderProps> = ({ activeTab, setActiveTab }) => {
  const { mode, variant, colors, language, setMode, setVariant, setLanguage } = useTheme();

  const navItems = [
    { id: 'home', label: 'Home', icon: Sparkles },
    { id: 'sandbox', label: 'Code Sandbox', icon: Code2 },
    { id: 'resume', label: 'Resume Risk Map', icon: FileText },
    { id: 'mock', label: 'AI Mock Interview', icon: Bot },
    { id: 'companies', label: 'Company Tracks', icon: Building2 },
    { id: 'job-analyzer', label: 'Job Gap Matcher', icon: Briefcase },
    { id: 'packs', label: 'Prep Packs', icon: Package },
    { id: 'questions', label: 'Question Bank', icon: HelpCircle },
    { id: 'flashcards', label: 'Flashcards', icon: Layers },
    { id: 'study-plan', label: 'Study Plan', icon: Compass },
    { id: 'profile', label: 'Profile & Settings', icon: User },
  ];

  return (
    <header className={`sticky top-0 z-50 border-b glass-panel transition-colors duration-200 ${
      mode === 'dark' ? 'bg-[#0B0F19]/90 border-[#1E293B]' : 'bg-[#FFFFFF]/90 border-[#E2E8F0]'
    }`}>
      {/* Top Banner Bar */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 gap-4">
          
          {/* Logo */}
          <div className="flex items-center gap-3 cursor-pointer" onClick={() => setActiveTab('home')}>
            <div 
              className="w-10 h-10 rounded-xl flex items-center justify-center font-bold text-white shadow-lg transition-transform hover:scale-105"
              style={{ background: colors.gradient }}
            >
              <Code2 className="w-6 h-6" />
            </div>
            <div>
              <span className="font-heading font-extrabold text-xl tracking-tight">
                Intervue<span style={{ color: colors.primary }}>X</span>
              </span>
              <span className="hidden sm:inline-block ml-2 text-xs font-semibold px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-500 border border-emerald-500/20">
                PRO ENGINE v2.5
              </span>
            </div>
          </div>

          {/* Controls Right Section */}
          <div className="flex items-center gap-3">
            
            {/* Streak Counter */}
            <div className={`hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold border ${
              mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B] text-amber-400' : 'bg-[#F1F5F9] border-[#CBD5E1] text-amber-600'
            }`}>
              <Flame className="w-4 h-4 fill-amber-500 text-amber-500 animate-bounce" />
              <span>7 Day Streak</span>
            </div>

            {/* Language Selector */}
            <div className={`flex items-center gap-1 px-2.5 py-1.5 rounded-lg border text-xs font-semibold ${
              mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#CBD5E1]'
            }`}>
              <Globe className="w-3.5 h-3.5 opacity-70" />
              <select
                value={language}
                onChange={(e) => setLanguage(e.target.value as Language)}
                className="bg-transparent border-none outline-none cursor-pointer font-semibold text-xs"
              >
                <option value="en">EN</option>
                <option value="hi">HI</option>
                <option value="es">ES</option>
                <option value="fr">FR</option>
                <option value="de">DE</option>
              </select>
            </div>

            {/* Accent Variant Picker Dropdown */}
            <div className={`flex items-center gap-1 px-2.5 py-1.5 rounded-lg border text-xs font-semibold ${
              mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#CBD5E1]'
            }`}>
              <span 
                className="w-3 h-3 rounded-full inline-block" 
                style={{ backgroundColor: colors.primary }}
              />
              <select
                value={variant}
                onChange={(e) => setVariant(e.target.value as ThemeVariant)}
                className="bg-transparent border-none outline-none cursor-pointer font-semibold text-xs capitalize"
              >
                {Object.keys(THEME_VARIANTS).map((v) => (
                  <option key={v} value={v}>
                    {THEME_VARIANTS[v as ThemeVariant].name}
                  </option>
                ))}
              </select>
            </div>

            {/* Dark/Light Mode Toggle */}
            <button
              onClick={() => setMode(mode === 'dark' ? 'light' : 'dark')}
              className={`p-2 rounded-lg border transition-all hover:scale-105 ${
                mode === 'dark' 
                  ? 'bg-[#131B2E] border-[#1E293B] text-amber-400 hover:bg-[#1E293B]' 
                  : 'bg-white border-[#CBD5E1] text-indigo-600 hover:bg-[#F1F5F9]'
              }`}
              title="Toggle Dark / Light Theme"
            >
              {mode === 'dark' ? <Sun className="w-4 h-4" /> : <Moon className="w-4 h-4" />}
            </button>
          </div>
        </div>

        {/* Horizontal Navigation Scroll Bar for all 11 Views */}
        <div className="flex items-center gap-1 overflow-x-auto pb-2 scrollbar-none">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`flex items-center gap-2 px-3.5 py-2 rounded-lg text-xs font-bold transition-all whitespace-nowrap ${
                  isActive
                    ? 'text-white shadow-md scale-102'
                    : mode === 'dark'
                    ? 'text-slate-400 hover:text-white hover:bg-[#131B2E]'
                    : 'text-slate-600 hover:text-slate-900 hover:bg-[#F1F5F9]'
                }`}
                style={isActive ? { background: colors.gradient } : {}}
              >
                <Icon className={`w-4 h-4 ${isActive ? 'text-white' : ''}`} />
                <span>{item.label}</span>
              </button>
            );
          })}
        </div>
      </div>
    </header>
  );
};
