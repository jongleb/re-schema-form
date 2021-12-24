---
sidebar_position: 1
---

# Getting started

Let's **Install**.

## Install Re schema form

Add it to you dependencies using npm or yarn:

```shell
yarn add re-schema-form
# or
npm install re-schema-form --save
```

## Update config

Update your bsconfig.json with:

```json
{
  "bs-dependencies": [
    "re-schema-form"
  ],
  "ppx-flags": ["re-schema-form/ppx"]
}
```

Done.

You can use schema decorator for generate your forms.
