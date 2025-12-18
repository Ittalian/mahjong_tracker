# Add Properties to Gambling Categories

Add detailed properties for Mahjong, Horse Racing, Boat Racing, Keirin, Auto Race, and Pachinko to allow for more detailed record keeping.

## User Review Required
> [!NOTE]
> `member` fields are defined as List<String>. The UI for adding members will be a simple comma-separated text input for now, or multiple text fields if preferred. I will implement as comma-separated string that parses to list for simplicity unless otherwise requested.

## Proposed Changes

### Models

#### [MODIFY] [mahjong_result.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/models/mahjong_result.dart)
- Add `type` (String)
- Add `umaRate` (String)
- Add `priceRate` (String)
- Add `chipRate` (int)
- Add `member` (List<String>)
- Update `fromFirestore` and `toMap`

#### [MODIFY] [pachinko_result.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/models/pachinko_result.dart)
- Add `type` (String)
- Add `member` (List<String>)
- Add `place` (String)
- Add `machine` (String)
- Update `fromFirestore` and `toMap`

#### [MODIFY] [horse_racing_result.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/models/horse_racing_result.dart)
- Update `betType` validation/handling if necessary (though strictly model might just store string).

#### [MODIFY] [boat_racing_result.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/models/boat_racing_result.dart)
- Update `betType` validation.

#### [MODIFY] [keirin_result.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/models/keirin_result.dart)
- Update `betType` validation.

#### [MODIFY] [auto_racing_result.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/models/auto_racing_result.dart)
- Update `betType` validation.

### UI

#### [MODIFY] [edit_screen.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/screens/edit_screen.dart)
- Add DropdownButtonFormField for `type`, `umaRate`, `priceRate`, `chipRate` (Mahjong).
- Add DropdownButtonFormField for `betType` (Racing).
- Add DropdownButtonFormField for `type` (Pachinko).
- Add TextFormField for `place`, `machine` (Pachinko).
- Add Input logic for `member` (Mahjong, Pachinko).
- Update `_saveResult` to handle new fields.
- Update `CategoryHandler` maps to pass new fields to factories.

## Verification Plan

### Manual Verification
1.  **Mahjong**:
    - Select "Mahjong" category.
    - Check if "Type" (3-ma/4-ma), "Uma Rate", "Price Rate", "Chip Rate", "Member" fields appear.
    - Save and verify persistence.
2.  **Racing (Horse/Boat/Keirin/Auto)**:
    - Select each racing category.
    - Check "Bet Type" dropdown options match requirements.
3.  **Pachinko**:
    - Select "Pachinko".
    - Check "Type" (Solo/Group).
    - Select "Group" -> Check "Member" field appears.
    - Select "Solo" -> Check "Member" field disappears.
    - Check "Place", "Machine" fields.
    - Save and verify.
