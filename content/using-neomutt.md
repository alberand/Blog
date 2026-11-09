Title: How to use Neomutt - short guide
Date: 19.12.2024
Modified: 19.12.2024
Status: draft
Tags: pelican, publishing
Keywords: pelican, publishing
Slug: using-neomutt.md
Author: Andrey Albershtein
Summary: Neomutt settings and key mappings are confusing or non-standard in some way
Lang: en

Neomutt is a bit not obvious 

# Common key mappings

`<Ctrl>g` Cancel anything

# Search

Press `/` or `<esc>/` for reverse search.

Common patterns:

| Pattern | Description |
|---------|-------------|
| `~b PAT` | Body/content matches PAT |
| `~B PAT` | Entire message matches PAT |
| `~c PAT` | Recipient (to/cc/bcc) matches PAT |
| `~C PAT` | Message is either to: or cc: PAT |
| `~d [MIN]-[MAX]` | Message is within date range |
| `~f PAT` | From matches PAT |
| `~F` | Flagged messages |
| `~i PAT` | Message-id matches PAT |
| `~L PAT` | Message is either originated or received by PAT |
| `~p` | Message is addressed to you |
| `~P` | Message is from you |
| `~s PAT` | Subject matches PAT |
| `~t PAT` | To: matches PAT |

The rest:

| Pattern | Description |
|---------|-------------|
| `~A` | All messages |
| `~D` | Deleted messages |
| `~e PAT` | Sender is in PAT's address book entry |
| `~E` | Expired messages |
| `~g` | Cryptographically signed messages |
| `~G` | Cryptographically encrypted messages |
| `~h PAT` | Any header matches PAT |
| `~H PAT` | Message has threading information |
| `~k` | Message contains PGP key |
| `~l` | Address the user has subscribed to |
| `~m [MIN]-[MAX]` | Message in the range MIN to MAX |
| `~n [MIN]-[MAX]` | Score within range MIN to MAX |
| `~N` | New messages |
| `~O` | Old messages |
| `~Q` | Messages which have been replied to |
| `~r [MIN]-[MAX]` | Messages received within date range |
| `~R` | Read messages |
| `~S` | Superseded messages |
| `~T` | Tagged messages |
| `~u` | Messages addressed to a subscribed mailing list |
| `~U` | Unread messages |
| `~v` | Messages part of a collapsed thread |
| `~V` | Cryptographically verified messages |
| `~x PAT` | References matches PAT |
| `~X [MIN]-[MAX]` | Message size within range MIN to MAX |
| `~y PAT` | X-Label: matches PAT |
| `~z [MIN]-[MAX]` | Message has lines within range MIN to MAX |
| `~=` | Duplicated messages |
| `~$` | Messages in subscribed mailboxes |

1. Search in messages by content/metadata:

```
~b important                # Find "important" in message body
~s meeting                  # Find "meeting" in subject
~f boss@company.com         # Messages from specific sender
~t team@company.com         # Messages sent to specific recipient
~B confidential             # Search entire message for "confidential"
```

2. Date-based search:
```
~d >1w                      # Messages older than 1 week
~d <2d                      # Messages newer than 2 days
~d 01/01/24-31/01/24        # Messages from January 2024
```

3. Common combinations:
```
~N ~f boss@company.com      # New messages from boss
~U ~s urgent               # Unread messages with "urgent" in subject
~d <1w ~F                  # Flagged messages from last week
~b report ~s monthly       # "report" in body AND "monthly" in subject
~f alice | ~f bob          # Messages from either Alice OR Bob
```
