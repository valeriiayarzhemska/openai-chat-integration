import useSWRMutation from 'swr/mutation';
import { useSWRConfig } from 'swr';
import type { Todo, CreateTodoDto, UpdateTodoDto } from '@/types/todo';
import { sendRequest } from '../lib/fetcher';
import { todoCacheKeys } from '../lib/cacheKeys';

export function useCreateTodo() {
  const { mutate } = useSWRConfig();

  const { trigger, isMutating, error } = useSWRMutation(
    '/api/todos',
    async (url: string, { arg }: { arg: CreateTodoDto }) => {
      const result = await sendRequest<Todo>(url, {
        arg: { method: 'POST', body: arg },
      });

      // Invalidate all list caches after successful creation
      mutate(todoCacheKeys.allListsPattern());

      return result;
    },
  );

  return { createTodo: trigger, isCreating: isMutating, error };
}

export function useUpdateTodo() {
  const { mutate } = useSWRConfig();

  const { trigger, isMutating, error } = useSWRMutation(
    '/api/todos',
    async (
      url: string,
      { arg }: { arg: { id: number; data: UpdateTodoDto } },
    ) => {
      const result = await sendRequest<Todo>(`${url}/${arg.id}`, {
        arg: { method: 'PUT', body: arg.data },
      });

      mutate(todoCacheKeys.allListsPattern());
      mutate(todoCacheKeys.detail(arg.id));

      return result;
    },
  );

  return { updateTodo: trigger, isUpdating: isMutating, error };
}

export function useDeleteTodo() {
  const { mutate } = useSWRConfig();

  const { trigger, isMutating, error } = useSWRMutation(
    '/api/todos',
    async (url: string, { arg }: { arg: number }) => {
      const result = await sendRequest(`${url}/${arg}`, {
        arg: { method: 'DELETE' },
      });

      mutate(todoCacheKeys.allListsPattern());
      mutate(todoCacheKeys.detail(arg));

      return result;
    },
  );

  return { deleteTodo: trigger, isDeleting: isMutating, error };
}
