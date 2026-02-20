"use client";

import { useRef, useEffect, useState, type KeyboardEvent } from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Textarea } from "@/components/ui/textarea";
import { useChatStore } from "@/lib/stores/chat-store";
import { chefPresets } from "@/lib/gemini";

export default function ChatPage() {
  const {
    messages,
    selectedPresetId,
    isLoading,
    error,
    sendMessage,
    setPreset,
    clearMessages,
  } = useChatStore();

  const [input, setInput] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const selectedPreset = chefPresets.find((p) => p.id === selectedPresetId);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleSend = () => {
    const trimmed = input.trim();
    if (!trimmed || isLoading) return;
    setInput("");
    sendMessage(trimmed);
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div className="container mx-auto flex flex-col lg:flex-row gap-4 p-4 h-[calc(100vh-3.5rem)]">
      {/* Sidebar: Chef presets */}
      <aside className="lg:w-64 shrink-0">
        <Card className="p-3">
          <div className="flex items-center justify-between mb-3">
            <h2 className="font-semibold text-sm">AI 셰프 선택</h2>
            <Button variant="ghost" size="sm" onClick={clearMessages}>
              초기화
            </Button>
          </div>
          <div className="grid grid-cols-4 lg:grid-cols-2 gap-2">
            {chefPresets.map((preset) => (
              <button
                key={preset.id}
                onClick={() => setPreset(preset.id)}
                className={`flex flex-col items-center p-2 rounded-lg text-xs transition-colors ${
                  selectedPresetId === preset.id
                    ? "bg-primary text-primary-foreground"
                    : "hover:bg-muted"
                }`}
              >
                <span className="text-2xl mb-1">{preset.emoji}</span>
                <span className="truncate w-full text-center">
                  {preset.name}
                </span>
              </button>
            ))}
          </div>
        </Card>
      </aside>

      {/* Chat area */}
      <div className="flex-1 flex flex-col min-h-0">
        {/* Messages */}
        <div className="flex-1 overflow-y-auto space-y-4 pb-4">
          {messages.length === 0 && (
            <div className="flex flex-col items-center justify-center h-full text-muted-foreground">
              <span className="text-6xl mb-4">{selectedPreset?.emoji}</span>
              <p className="text-lg font-medium">
                {selectedPreset?.name ?? "AI 셰프"}에게 물어보세요!
              </p>
              <p className="text-sm">
                {selectedPreset?.description}
              </p>
            </div>
          )}

          {messages.map((msg) => (
            <div
              key={msg.id}
              className={`flex gap-3 ${
                msg.role === "user" ? "justify-end" : "justify-start"
              }`}
            >
              {msg.role === "assistant" && (
                <Avatar className="h-8 w-8 shrink-0">
                  <AvatarFallback className="text-sm">
                    {selectedPreset?.emoji ?? "🧑‍🍳"}
                  </AvatarFallback>
                </Avatar>
              )}
              <Card
                className={`max-w-[75%] p-3 ${
                  msg.role === "user"
                    ? "bg-primary text-primary-foreground"
                    : "bg-muted"
                }`}
              >
                <p className="text-sm whitespace-pre-wrap">{msg.content}</p>
              </Card>
            </div>
          ))}

          {isLoading && (
            <div className="flex gap-3 justify-start">
              <Avatar className="h-8 w-8 shrink-0">
                <AvatarFallback className="text-sm">
                  {selectedPreset?.emoji ?? "🧑‍🍳"}
                </AvatarFallback>
              </Avatar>
              <Card className="p-3 bg-muted">
                <div className="flex gap-1">
                  <span className="animate-bounce">.</span>
                  <span className="animate-bounce" style={{ animationDelay: "0.1s" }}>.</span>
                  <span className="animate-bounce" style={{ animationDelay: "0.2s" }}>.</span>
                </div>
              </Card>
            </div>
          )}

          {error && (
            <div className="text-center text-destructive text-sm">
              {error}
            </div>
          )}

          <div ref={messagesEndRef} />
        </div>

        {/* Input */}
        <div className="flex gap-2 pt-2 border-t">
          <Textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="메시지를 입력하세요... (Enter로 전송, Shift+Enter로 줄바꿈)"
            className="resize-none min-h-[44px] max-h-32"
            rows={1}
            disabled={isLoading}
          />
          <Button
            onClick={handleSend}
            disabled={!input.trim() || isLoading}
            className="shrink-0"
          >
            전송
          </Button>
        </div>
      </div>
    </div>
  );
}
