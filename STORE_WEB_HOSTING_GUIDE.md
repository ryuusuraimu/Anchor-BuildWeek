# Anchor Store Web Hosting Guide

Last updated: 2026-07-08

## Goal

Publish the required App Store web URLs:

- Privacy Policy URL
- Support URL

Prepared files:

- `StoreWeb/privacy.html`
- `StoreWeb/support.html`

## Fastest GitHub Pages Option

If using the existing GitHub repository, enable GitHub Pages and publish the `StoreWeb` files.

Suggested public paths:

```text
https://ryuusuraimu.github.io/Anchor-BuildWeek/privacy.html
https://ryuusuraimu.github.io/Anchor-BuildWeek/support.html
```

If GitHub Pages is configured to publish from a `/docs` folder instead, copy:

```text
StoreWeb/privacy.html -> docs/privacy.html
StoreWeb/support.html -> docs/support.html
```

Then set GitHub Pages source to the `docs` folder.

## App Store Connect Fields

Use:

- Privacy Policy URL: the public URL for `privacy.html`
- Support URL: the public URL for `support.html`

Marketing URL is optional for v1.

## Pre-Submission Check

Before submitting:

1. Open both URLs in a private browser window.
2. Confirm they load without authentication.
3. Confirm the privacy page says local storage, optional Contacts, no account, no analytics/ads in v1.
4. Confirm the support page says Anchor is not medical care or emergency service.

## Keep In Sync

If the app later adds analytics, ads, sync, accounts, crash reporting, photo saving, location, notifications through a server, or external APIs, update:

- App Privacy answers
- Privacy policy
- Support page if user-facing behavior changes
