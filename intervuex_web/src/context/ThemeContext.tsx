import React, { createContext, useContext, useState, useEffect } from 'react';
import type { ThemeMode, ThemeVariant, ThemeVariantColors, Language } from '../types';

export const THEME_VARIANTS: Record<ThemeVariant, ThemeVariantColors> = {
  ocean: {
    name: 'Ocean',
    primary: '#0EA5E9',
    light: '#38BDF8',
    gradientEnd: '#0369A1',
    gradient: 'linear-gradient(135deg, #0EA5E9 0%, #0369A1 100%)',
  },
  purple: {
    name: 'Purple (Default)',
    primary: '#4F46E5',
    light: '#818CF8',
    gradientEnd: '#7C3AED',
    gradient: 'linear-gradient(135deg, #4F46E5 0%, #7C3AED 100%)',
  },
  emerald: {
    name: 'Emerald',
    primary: '#10B981',
    light: '#34D399',
    gradientEnd: '#059669',
    gradient: 'linear-gradient(135deg, #10B981 0%, #059669 100%)',
  },
  sunset: {
    name: 'Sunset',
    primary: '#F97316',
    light: '#FB923C',
    gradientEnd: '#EA580C',
    gradient: 'linear-gradient(135deg, #F97316 0%, #EA580C 100%)',
  },
  rose: {
    name: 'Rose',
    primary: '#E11D48',
    light: '#FB7185',
    gradientEnd: '#9F1239',
    gradient: 'linear-gradient(135deg, #E11D48 0%, #9F1239 100%)',
  },
  midnight: {
    name: 'Midnight',
    primary: '#6366F1',
    light: '#A5B4FC',
    gradientEnd: '#4338CA',
    gradient: 'linear-gradient(135deg, #6366F1 0%, #4338CA 100%)',
  },
};

interface ThemeContextType {
  mode: ThemeMode;
  variant: ThemeVariant;
  colors: ThemeVariantColors;
  language: Language;
  targetRole: string;
  setMode: (mode: ThemeMode) => void;
  setVariant: (variant: ThemeVariant) => void;
  setLanguage: (lang: Language) => void;
  setTargetRole: (role: string) => void;
  toggleMode: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [mode, setMode] = useState<ThemeMode>('dark');
  const [variant, setVariant] = useState<ThemeVariant>('purple');
  const [language, setLanguage] = useState<Language>('en');
  const [targetRole, setTargetRole] = useState<string>('Senior Software Engineer (SDE-2)');

  const colors = THEME_VARIANTS[variant];

  const toggleMode = () => {
    setMode((prev) => (prev === 'dark' ? 'light' : 'dark'));
  };

  useEffect(() => {
    const root = document.documentElement;
    if (mode === 'dark') {
      root.classList.add('dark');
      root.style.backgroundColor = '#0B0F19';
      root.style.color = '#F8FAFC';
    } else {
      root.classList.remove('dark');
      root.style.backgroundColor = '#F8FAFC';
      root.style.color = '#0F172A';
    }
  }, [mode]);

  return (
    <ThemeContext.Provider
      value={{
        mode,
        variant,
        colors,
        language,
        targetRole,
        setMode,
        setVariant,
        setLanguage,
        setTargetRole,
        toggleMode,
      }}
    >
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};
