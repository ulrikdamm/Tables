# Tables

Tables is a library for turning UITablesViews from a mess of delegation and state-keeping, into something simple and declarative. Simply specify which rows you want in your tableview, and they will be inserted with the correct animations. Tables also decouple your view code from your table view data, so you can completely change the style of your cells without modifying your viewcontroller.

## Examples

Here’s a login form in a tableview:

![Demo app screenshot](https://raw.githubusercontent.com/ulrikdamm/Tables/master/demo.png)

This is the code that generates the tableview cells:

```swift
func generateSections() -> [Section] {
	let nameRow = TextInputCell(
		id: "name",
		title: "Name",
		placeholder: "Donald Duck",
		enabled: !loading,
		invalid: nameInvalid,
		value: name,
		valueChanged: { [weak self] in self?.name = $0 },
		done: { [weak self] _ in self?.selectRow("email") }
	)
	
	let emailRow = TextInputCell(
		id: "email",
		title: "Email",
		placeholder: "donald@duck.com",
		enabled: !loading,
		invalid: emailInvalid,
		value: email,
		valueChanged: { [weak self] in self?.email = $0 },
		done: { [weak self] _ in self?.submit() }
	)
	
	let inputSection = Section("input", header: "User formation", rows: [nameRow, emailRow])
	
	let submitRow = ButtonCell(
		id: "submit",
		title: "Submit",
		enabled: !loading,
		loading: loading,
		action: { [weak self] in self?.submit() }
	)
	
	let submitSection = Section("submit", rows: [submitRow])
	
	return [inputSection, submitSection]
}
```

To update your tableview with these sections, just call this:

```swift
contentView.tablesDataSource.update(generateSections())
```

And your tableview will be reloaded if needed.

Tables also support things that are typically very annoying to do very simply. Like, to make a row deletable, just add `EditableCellType` to your cell type, and set the `deleteAction`. There’s examples of all this in the sample app.

## Cutomization

Tables is very customizable. You can set the `cellTypeForRow` property on the `tablesDataSource`, and you can specify yourself which `UITableViewCell` subclasses you want for different cell types.

You can also make your own cell types, just making a struct that implements `CellType` is all you need to do. You can also do custom cell types that uses built in functionality by implementing more protocols. For example, you can implement `DetailsCellType` (to make it pressable and add a disclosure indicator), `EditableCellType` (to make it deletable by left-swiping on the cell) and `SpinnerCellType` (to be able to show an activity indicator in the cell), and then extend it with your own data. Then for displaying this, you make a subclass of the `TablesPlainCell`, and register that cell for your cell type in `cellTypeForRow`.
