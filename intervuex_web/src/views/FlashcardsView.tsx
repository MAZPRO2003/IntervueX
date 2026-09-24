import React, { useState } from 'react';
import { useTheme } from '../context/ThemeContext';
import { MOCK_FLASHCARDS } from '../mockData';
import { Layers, RotateCw, CheckCircle, RefreshCw } from 'lucide-react';

export const FlashcardsView: React.FC = () => {
  const { mode, colors } = useTheme();

  const [currentIndex, setCurrentIndex] = useState<number>(0);
  const [isFlipped, setIsFlipped] = useState<boolean>(false);

  const card = MOCK_FLASHCARDS[currentIndex % MOCK_FLASHCARDS.length];

  return (
    <div className="space-y-6 pb-12 max-w-3xl mx-auto">
      {/* Header */}
      <div className={`p-6 rounded-2xl border text-center ${
        mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
      }`}>
        <h1 className="font-heading font-extrabold text-2xl flex items-center justify-center gap-2">
          <Layers className="w-6 h-6 text-sky-400" />
          <span>Interactive Computer Science Flashcards</span>
        </h1>
        <p className={`text-xs ${mode === 'dark' ? 'text-slate-400' : 'text-slate-600'}`}>
          Tap card to flip front/back. Rate your recall for spaced repetition learning.
        </p>
      </div>

      {/* Flip Card Surface */}
      <div
        onClick={() => setIsFlipped(!isFlipped)}
        className={`p-8 rounded-3xl border min-h-[320px] flex flex-col justify-between cursor-pointer transition-all duration-300 shadow-2xl ${
          mode === 'dark' ? 'bg-[#131B2E] border-[#1E293B]' : 'bg-white border-[#E2E8F0]'
        }`}
      >
        <div className="flex items-center justify-between">
          <span className="text-xs font-bold px-3 py-1 rounded-md bg-purple-500/15 text-purple-400">
            {card.category}
          </span>
          <span className="text-xs font-bold text-slate-400 flex items-center gap-1">
            <RotateCw className="w-3.5 h-3.5" /> Tap to Flip
          </span>
        </div>

        <div className="my-6 space-y-3 text-center">
          {!isFlipped ? (
            <h2 className="font-heading font-extrabold text-2xl sm:text-3xl">{card.question}</h2>
          ) : (
            <div className="space-y-4">
              <p className="text-sm sm:text-base text-emerald-400 font-medium leading-relaxed">{card.answer}</p>
              {card.codeSnippet && (
                <pre className={`p-3 rounded-xl font-code text-xs text-left overflow-x-auto ${
                  mode === 'dark' ? 'bg-[#0B0F19] text-slate-300' : 'bg-[#F8FAFC] text-slate-800'
                }`}>
                  {card.codeSnippet}
                </pre>
              )}
            </div>
          )}
        </div>

        <div className="text-center text-xs font-bold text-slate-500">
          Card {currentIndex + 1} of {MOCK_FLASHCARDS.length}
        </div>
      </div>

      {/* Spaced Repetition Buttons */}
      <div className="flex items-center justify-center gap-4">
        <button
          onClick={() => {
            setIsFlipped(false);
            setCurrentIndex((prev) => prev + 1);
          }}
          className="px-6 py-3 rounded-xl bg-amber-500/15 text-amber-400 font-bold text-xs border border-amber-500/20 hover:bg-amber-500/25 transition-all flex items-center gap-2"
        >
          <RefreshCw className="w-4 h-4" /> Review Again Later
        </button>

        <button
          onClick={() => {
            setIsFlipped(false);
            setCurrentIndex((prev) => prev + 1);
          }}
          className="px-6 py-3 rounded-xl font-bold text-xs text-white shadow-lg transition-transform active:scale-95 flex items-center gap-2"
          style={{ background: colors.gradient }}
        >
          <CheckCircle className="w-4 h-4" /> Got It Mastered
        </button>
      </div>
    </div>
  );
};
