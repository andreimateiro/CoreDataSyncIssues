# CoreDataSyncIssues

1) Run app to init schema
1.1) Go to CKDashboard and add the 2 needed indexes for public databases.

2) Run macOS app -> hit "Import for json"
2.1) Observe the changes on CKDashboard

3) Run iOS app -> observe the changes via "DB Browser for SQLLite"

4) Update a.json and increment the first A.revision to 1, and modify each "B" (e.g. modife name from 1 2 3 to 4 5 6 or anything else).
4.1) Restart macOS app and import
4.2) Observe the CK Dashabord, the update is instant
4.3) Observe the iOS app via DB Browser
4.4) If the changes are reflected, redo step 4). Usually the inconsisteny occurs at least once at 1-2 runs. 

tested on iOS version 14.2
