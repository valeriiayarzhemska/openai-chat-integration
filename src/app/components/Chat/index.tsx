'use client';

import { useState } from 'react';

type Message = {
  role: 'user' | 'assistant';
  content: string;
};

export default function Chat({
  sendMessage,
  messages,
  loading,
}: {
  sendMessage: (message: string) => Promise<void>;
  messages: Message[];
  loading: boolean;
}) {
  const [input, setInput] = useState('');

  return (
    <div className="p-12">
      <h1>AI Chat</h1>

      <div style={{ marginBottom: 20 }}>
        {messages.map((m, i) => (
          <div key={i}>
            <b>{m.role}:</b> {m.content}
          </div>
        ))}
      </div>

      <form
        onSubmit={async (e) => {
          e.preventDefault();
          await sendMessage(input);
        }}
        className="flex flex-col gap-2 w-62"
      >
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          disabled={loading}
          className="bg-gray-800"
          placeholder="Write message..."
        />

        <button type="submit" disabled={loading} className="bg-gray-900">
          Send
        </button>
      </form>
    </div>
  );
}
