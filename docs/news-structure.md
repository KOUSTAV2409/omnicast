# Omnicast news portal structure

Mirrored from [omarchy.org/news](https://omarchy.org/news) (HEY World card layout on Tokyo Night). Do not invent alternate chrome.

## Writing

- **No em dashes (—).** Prefer a colon, period, comma, or semicolon.
- Same rule for the landing page, README blurbs, tweets, and news posts.

## Index (`site/news/index.html`)

```
body.news-body
├── div.pre
│   └── a[href=home]
│       └── pre          ← green ASCII “OMNICAST” mark (mono)
├── header.header
│   └── h1               ← “Announcements, releases, and other news” (mono, blue)
└── main.news-page
    ├── p.news-feed      ← optional (RSS later)
    └── section.news-list
        └── article.news-card   ← repeat
            ├── header
            │   ├── p.news-meta
            │   │   ├── span.news-byline > a
            │   │   └── time.news-date
            │   └── h2.news-card__title
            ├── div.news-card__excerpt
            ├── a.news-card__link          ← stretched click target
            └── div.news-card__more[aria-hidden]
                └── span.news-card__button ← decorative “Read more”
```

## Post (`site/news/YYYY/MM/slug.html`)

```
body.news-body
├── div.pre.pre--news      ← smaller ASCII mark
│   └── a[href=home] > pre
└── main.news-page
    ├── article.news-post
    │   ├── header.news-post__header
    │   │   ├── p.news-meta   (“By … on …”)
    │   │   └── h1.news-post__title
    │   └── div.news-prose
    └── p.news-back            ← optional back link
```

## Typography rules

| Surface | Font |
|--------|------|
| `.pre pre` ASCII | JetBrains Mono, green |
| `.header h1` | JetBrains Mono, terminal blue |
| `.news-body` reading | System sans (HEY World scale) |
| code / pre in prose | JetBrains Mono |

## New post checklist

1. Add `site/news/YYYY/MM/slug.html` with post structure above  
2. Prepend a card to `site/news/index.html` (`div.news-card__excerpt`, not `<p>`)  
3. Deploy `site/` via Pages workflow  
