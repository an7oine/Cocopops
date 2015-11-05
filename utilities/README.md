### updateStrings.sh : an automation script for keeping localisations up-to-date in Xcode projects

To use it, create a new 'Run Script' build phase in your target with e.g. the following content:
```
( find . -name \*.storyboard -print0 && find . -name \*.m -print0 ) | xargs -0 Cocopops/utilities/updateStrings.sh . en
[ $? = 0 -o ${CONFIGURATION} = Debug ]
```

This will find (using `genstrings` and `ibtool`) all localised strings in `.m` and `.storyboard` files within the project root and reflect any changes in all languages. A development language (the language of strings inside your `NSLocalizedString...` invocations) of English (`en`) is assumed, and your `.lproj` directories are assumed to reside directly inside the current (project root) directory (`.`).

The second line ensures that any `Release` builds will fail if missing localisations are detected, preventing you from publishing partially translated versions by accident.
