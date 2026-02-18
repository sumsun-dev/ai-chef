'use client'

import { useState, useCallback } from 'react'

const STORAGE_KEY = 'ai-chef-visited'

function getInitialVisitState(): boolean {
  if (typeof window === 'undefined') return false
  return !localStorage.getItem(STORAGE_KEY)
}

export function useFirstVisit() {
  const [isFirstVisit, setIsFirstVisit] = useState(getInitialVisitState)

  const markAsVisited = useCallback(() => {
    localStorage.setItem(STORAGE_KEY, 'true')
    setIsFirstVisit(false)
  }, [])

  const resetVisit = useCallback(() => {
    localStorage.removeItem(STORAGE_KEY)
    setIsFirstVisit(true)
  }, [])

  return { isFirstVisit, isLoading: false, markAsVisited, resetVisit }
}
