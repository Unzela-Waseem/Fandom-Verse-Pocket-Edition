# Firestore backup and restore runbook

Status: prepared, **not active**. The owner must enable billing and grant the required IAM permissions before a schedule can be created. The production database is `fandom-verse-pocket-unzela/(default)` in `asia-south1`.

## Create and verify a daily schedule

After billing is enabled and `gcloud` is authenticated as a backup schedule administrator, run:

```bash
gcloud firestore backups schedules create --project=fandom-verse-pocket-unzela --database='(default)' --recurrence=daily --retention=7d
gcloud firestore backups schedules list --project=fandom-verse-pocket-unzela --database='(default)'
gcloud firestore backups list --project=fandom-verse-pocket-unzela --location=asia-south1 --format='table(name,database,state)'
```

The first command must be run only once. Record its schedule ID in the operations register. Check for a completed backup after the first scheduled run. Review backup states daily and alert the owner if no successful backup exists within the preceding 36 hours. Retention is seven days initially; revisit it with the project's recovery and privacy requirements.

Use `roles/datastore.backupSchedulesAdmin` for schedule administration, `roles/datastore.backupsViewer` for monitoring, and `roles/datastore.restoreAdmin` only for authorized restore operators. Avoid broad project Owner access for routine backup work. Restrict console access and audit IAM changes.

## Restore drill

1. List backups and select a completed backup from `asia-south1`.
2. Restore into a **new non-production database**. Never overwrite or delete the production database during a drill.
3. Compare representative user, content, event, merchandise, discussion, inquiry, and audit records; check indexes and application queries.
4. Record the chosen backup, operation ID, result, time, and any missing data. Repeat the drill after major schema changes and at least quarterly.

```bash
gcloud firestore backups list --project=fandom-verse-pocket-unzela --location=asia-south1
gcloud firestore databases restore --project=fandom-verse-pocket-unzela --source-backup=projects/fandom-verse-pocket-unzela/locations/asia-south1/backups/BACKUP_ID --destination-database=restore-drill-YYYYMMDD
```

Replace `BACKUP_ID` and the destination database name with reviewed values before running the restore. After verification, retain or remove the test database according to the owner's data retention policy; a restore drill can incur charges.

Official references: [Firestore backup and restore](https://cloud.google.com/firestore/docs/backups), [Firestore IAM roles](https://docs.cloud.google.com/iam/docs/roles-permissions/firestore).
