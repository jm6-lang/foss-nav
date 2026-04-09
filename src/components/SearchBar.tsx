import { useState, useMemo } from 'react';
import type { Tool } from '../data/tools';
import { categories } from '../data/tools';
import ToolCard from './ToolCard';

interface Props {
  tools: Tool[];
}

export default function SearchBar({ tools }: Props) {
  const [query, setQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState('all');

  const filtered = useMemo(() => {
    let result = tools;
    if (activeCategory !== 'all') {
      result = result.filter(t => t.category === activeCategory);
    }
    if (query.trim()) {
      const q = query.toLowerCase();
      result = result.filter(t =>
        t.name.toLowerCase().includes(q) ||
        t.nameEn.toLowerCase().includes(q) ||
        t.description.toLowerCase().includes(q) ||
        t.tags.some(tag => tag.toLowerCase().includes(q))
      );
    }
    return result;
  }, [tools, query, activeCategory]);

  return (
    <div className="w-full max-w-5xl mx-auto mb-10">
      {/* 搜索框 */}
      <div className="relative mb-6">
        <input
          type="text"
          value={query}
          onChange={e => setQuery(e.target.value)}
          placeholder="搜索工具名称、标签或描述..."
          className="w-full px-5 py-4 pl-12 text-lg rounded-2xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent shadow-sm transition-all"
        />
        <span className="absolute left-4 top-1/2 -translate-y-1/2 text-2xl">🔍</span>
        {query && (
          <button
            onClick={() => setQuery('')}
            className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 text-xl"
          >
            ✕
          </button>
        )}
      </div>

      {/* 分类筛选 */}
      <div className="flex flex-wrap gap-2 mb-6">
        <button
          onClick={() => setActiveCategory('all')}
          className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${
            activeCategory === 'all'
              ? 'bg-blue-600 text-white shadow-md'
              : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
          }`}
        >
          🏠 全部
        </button>
        {categories.map(cat => {
          const count = tools.filter(t => t.category === cat.id).length;
          return (
            <button
              key={cat.id}
              onClick={() => setActiveCategory(cat.id)}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${
                activeCategory === cat.id
                  ? 'bg-blue-600 text-white shadow-md'
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
              }`}
            >
              {cat.icon} {cat.name} <span className="opacity-60 text-xs">({count})</span>
            </button>
          );
        })}
      </div>

      {/* 搜索/筛选结果统计 */}
      {(query || activeCategory !== 'all') && (
        <div className="mb-4 text-sm text-gray-500 dark:text-gray-400">
          找到 <strong>{filtered.length}</strong> 个结果
          {query && <>（搜索 "<em>{query}</em>"）</>}
        </div>
      )}

      {/* 工具卡片网格 */}
      {filtered.length > 0 ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map(tool => (
            <ToolCard key={tool.id} tool={tool} />
          ))}
        </div>
      ) : (
        <div className="text-center py-20 text-gray-400 dark:text-gray-500">
          <div className="text-5xl mb-4">🔎</div>
          <p className="text-lg">没有找到匹配的工具</p>
          <p className="text-sm mt-2">试试其他关键词，或切换分类</p>
        </div>
      )}
    </div>
  );
}
