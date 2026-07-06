---
name: project-notification-system
description: "Notification system framework built across designflow-backend and designflow-frontend — @mentions, task assignments, real-time badge, mark-as-read"
metadata: 
  node_type: memory
  type: project
  originSessionId: fa01c9cb-a235-49b9-9f41-206dbb94704b
---

## Notification framework built (2026-05-21)

Core foundation is in place. Here's what was built and where.

### Backend (designflow-backend)

| File | Purpose |
|---|---|
| `helpers/mention.js` | `parseMentions(text)` → array of @handles; `resolveMentions(handles, users)` → user IDs |
| `services/notification.service.js` | CRUD: `createNotification`, `createManyNotifications`, `getUnreadCount`, `markAsRead`, `markAllAsRead`, `getMentionableUsers` |
| `controllers/notification.controller.js` | Express handlers for each route (`SYS-N01` through `SYS-N05` error codes) |
| `routes/notification.router.js` | Routes under `/api/notifications/*` |
| `routes/index.js` | Registered notification router |
| `controllers/comment.controller.js` | Triggers @mention notifications after `addComment` (async, non-blocking) |

#### API endpoints (all require auth, any role)
- `GET /api/notifications/count` → `{ count: number }` (unread count)
- `GET /api/notifications/mentionable-users` → active users for @mention autocomplete
- `POST /api/notifications/create` → create a notification for a user
- `PATCH /api/notifications/:id/read` → mark one as read
- `POST /api/notifications/read-all` → mark all as read for current user

#### Existing endpoints (unchanged)
- `GET /getnotifications` → returns all unread `user_notification` records for current user
- `POST /markNotificationAsRead` → marks one by `{ id }` (body)

### Frontend (designflow-frontend)

| File | Purpose |
|---|---|
| `src/app/helpers/services/notification.service.ts` | `NotificationService` (providedIn: root): polls `/api/notifications/count` every 30s, exposes `unreadCount$` BehaviorSubject; also `markAsRead`, `markAllAsRead`, `getMentionableUsers`, `createNotification` |
| `src/@vex/layout/toolbar/toolbar.component.ts` | Injects `NotificationService`, starts polling on init, exposes `unreadCount$` |
| `src/@vex/layout/toolbar/toolbar.component.html` | Red badge pill on the bell icon (capped at 99+) |
| `src/app/pages/notifications/notifications.component.ts` | Updated to show two tabs: Alerts (general `user_notification`) + Licensing |
| `src/app/pages/notifications/notifications.component.html` | Tab UI + alert rows with mark-as-read button + mark-all button |
| `src/app/pages/notifications/notifications.component.scss` | Added tab styles, alert row styles, unread dot, mark-as-read button |

### database schema (user_notification)
Fields: `id`, `type`, `event`, `title`, `message`, `unread` (bool), `created_date`, `user_id_fk`
- `type`: `mention`, `task_assignment`, or custom
- `event`: `comment_mention`, `task_assigned`, etc.

### @Mention autocomplete (built 2026-05-21)

| File | Purpose |
|---|---|
| `src/app/pages/comments/mention-picker/mention-picker.component.ts` | Standalone floating dropdown; `mousedown` (not click) to preserve Quill focus; shows avatar initials + name + email |
| `src/app/pages/comments/comment-form/comment-form.component.ts` | Loads mentionable users on init; detects `@` in `(onContentChanged)` — looks back from cursor to last `@`, extracts partial, filters, shows picker; `onMentionPicked()` deletes partial and inserts `@FirstName ` via Quill API |
| `src/app/pages/comments/comment-form/comment-form.component.html` | Wraps quill-editor in `.quill-wrapper` (position:relative); embeds `<app-mention-picker>` inside; wires `(onEditorCreated)` and `(onContentChanged)` |
| `src/app/pages/comments/comments.module.ts` | Imports `MentionPickerComponent` (standalone) |

**Key design:** uses `mousedown` instead of `click` so Quill doesn't lose focus/selection before `onMentionPicked()` reads cursor position.

### Task assignment dialog (built 2026-05-21)

| File | Purpose |
|---|---|
| `src/app/pages/tasks/assign-task-dialog.component.ts` | Standalone; loads users via `getMentionableUsers()`; multi-select with search; calls `createNotification()` for each assignee with `type:'task_assignment'` |
| `src/app/pages/tasks/assign-task-dialog.component.html` | Chip display of selected users, task description textarea, searchable user list, success state |
| `src/app/pages/tasks/assign-task-dialog.component.scss` | Full styles |
| `src/@vex/layout/toolbar/toolbar.component.ts` | Injects `MatDialog`; `openAssignTaskDialog()` opens the dialog at 520px |
| `src/@vex/layout/toolbar/toolbar.module.ts` | Added `MatDialogModule` |
| `src/@vex/layout/toolbar/toolbar.component.html` | "Add Task" menu item wired to `openAssignTaskDialog()` |

### What's NOT yet built (next steps)
- Mark-as-read auto-trigger when user navigates to item from an alert row
- Keyboard navigation (↑↓ Enter Escape) in the mention picker
- @mention autocomplete in other text inputs (currently only in the Quill comment editor)
- Task assignment from item detail / RFQ grid context (currently only via toolbar menu)

**Why:** User wanted framework for @mentions + task assignments with in-app badge and real-time updates (polling). Badge polls every 30s. @mention notifications fire automatically when a comment with @Name is saved.

**How to apply:** When building @mention autocomplete UI, use `notificationService.getMentionableUsers()` for the user list. Format mentions as `@FirstName` or `@FirstName.LastName` — the backend parser handles both.
