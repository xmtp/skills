# FilePicker Component

File selection UI for message attachments with validation and drag-drop support.

## Interface

```typescript
type FileValidationError =
  | { type: 'size'; maxSizeMB: number; actualSizeMB: number }
  | { type: 'format'; accepted: string[]; actual: string };

interface FilePickerProps {
  onSelect: (file: File) => void;
  onError?: (error: FileValidationError) => void;
  accept?: string[];
  maxSizeMB?: number;
  className?: string;
}
```

## UX Rules

**MUST:**
- Validate file size/type before calling `onSelect`
- Call `onError` for rejected files with reason
- Support drag-and-drop onto message input area

**NEVER:**
- Call `onSelect` with invalid files

**ACCESSIBILITY:**
- Keyboard navigable (Enter/Space to open)
- Screen reader label: "Attach file"

## Look Up

Before implementing, check:

1. **Existing file upload patterns**: Does app have file selection UI?
2. **Icon library**: What attachment/paperclip icon is available?
3. **Drag-drop patterns**: Prerequisite frontend-design skill
