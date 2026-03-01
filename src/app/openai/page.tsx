'use client';

import { useState } from 'react';
import Chat from '../components/Chat';

type Message = {
  role: 'user' | 'assistant';
  content: string;
};

export default function Openai() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(false);

  const sendMessage = async (input: string) => {
    if (!input.trim()) {
      return;
    }

    const newMessages = [
      ...messages,
      { role: 'user' as const, content: input },
    ];

    setMessages(newMessages);
    setLoading(true);

    try {
      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ messages: newMessages }),
      });

      if (!res.ok) {
        throw new Error('Server error');
      }

      const data = await res.json();

      if (data?.message) {
        setMessages([...newMessages, data.message]);
      }
    } catch (error) {
      console.error('Chat error:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Chat sendMessage={sendMessage} messages={messages} loading={loading} />
  );
}
