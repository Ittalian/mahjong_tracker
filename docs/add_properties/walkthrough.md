# Added Properties to Gambling Categories

Updated models and UI to support detailed recording for Mahjong, Horse Racing, Boat Racing, Keirin, Auto Race, and Pachinko.

## Changes

### Models

- **Mahjong**:
  - Added `type` (3-ma/4-ma), `umaRate`, `priceRate`, `chipRate`, and `member` list.
  - **Refinement**: "Uma Rate" options now filter based on the selected "Type" (3-ma: 10, 15; 4-ma: 10-20, 10-30). The field is hidden if no type is selected.
- **Validation**: Added required field validation for all categories (except `memo` and Pachinko `member` when type is Solo).
- **Member Input**: Changed from comma-separated text to dynamic list. Users can now add/remove member fields individually using "+" and "-" buttons.
- **Deletion**: Changed deletion interaction from long-press to a dedicated trash icon button on each result card to improve usability.
- **Pachinko**: Added `type` (Solo/Group), `member` list, `place`, `machine`.
- **Racing (Horse/Boat/Keirin/Auto)**: Added static lists of valid `betTypes` for UI dropdowns.

### UI to `EditScreen`

- **Dynamic Forms**: The form now changes based on the selected category.
- **Mahjong**: Dropdowns for game settings and member input.
- **Racing**: Dropdown for specific bet types (e.g., '単勝', '3連単').
- **Pachinko**: Toggle for 'Solo' vs 'Group' (Group shows member input), plus Place and Machine fields.
- **Member Input**: Implemented as a comma-separated text field for simplicity.

## Verification

### Automated Checks
- Ran `flutter analyze lib/screens/edit_screen.dart`: **Passed** (No issues found).

### manual Verification Steps (Recommended)
1. Open the app and navigate to "Add" or "Edit" (FAB).
2. Select **Mahjong**: Verify all new dropdowns and member field appear.
3. Select **Horse Racing**: Verify "Bet Type" dropdown contains racing-specific options.
4. Select **Pachinko**:
   - Verify "Type" dropdown defaults to "Solo".
   - Switch to "Group" (乗り打ち): Verify "Member" field appears.
   - Switch back to "Solo": Verify "Member" field disappears.
   - Verify "Place" and "Machine" fields are present.
5. Save a record for each type and verify it allows saving without error. (Persistence logic was updated to map these fields to Firestore).
