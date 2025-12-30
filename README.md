## DR TV Guide Scraper (Ruby)

This is a **very simple** Ruby scraper that fetches the TV program schedule from:

`https://www.dr.dk/drtv/tv-guide`

For each program it tries to capture:

- Channel name  
- Program start time  
- Program title  
- Program end time (guessed from the next program’s start time)

> Note: The exact CSS classes on the DR site can change.  
> If you get empty results, open the page in your browser, inspect the HTML, and update the CSS selectors in `scraper.rb`.

---

### 1. Dependencies & Installation

Requirements:

- Ruby (2.7+ or 3.x)
- Bundler (`gem install bundler`) – optional but recommended

Install gems (from inside the `ruby_tv_scraper` folder):

```bash
bundle install
```

This will install:

- `httparty`
- `nokogiri`

If you do not want to use Bundler, you can also run:

```bash
gem install httparty
gem install nokogiri
```

---

### 2. How to Run

From inside the `ruby_tv_scraper` folder:

#### a) Run for **today**:

```bash
ruby scraper.rb
```

#### b) Run for a **specific date** (format: `YYYY-MM-DD`):

```bash
ruby scraper.rb 2025-12-30
```

This will:

1. Fetch the DR TV guide page.  
2. Print a simple schedule in the terminal.  
3. Create a JSON file named, for example:  
   `tv_schedule_2025-12-30.json`

---

### 3. Output Format

#### Console (text)

Each program is printed like:

```text
[CHANNEL] START - END : TITLE
```

Example:

```text
[DR1] 20:00 - 20:30 : TV Avisen
[DR1] 20:30 - 21:00 : Vejret
```

If the end time is unknown (last program of the list), it shows `??:??`.

#### JSON file

The JSON file is an array of simple objects:

```json
[
  {
    "channel_name": "DR1",
    "start_time": "20:00",
    "title": "TV Avisen",
    "end_time": "20:30"
  },
  {
    "channel_name": "DR1",
    "start_time": "20:30",
    "title": "Vejret",
    "end_time": "21:00"
  }
]
```

---

### 4. Updating CSS Selectors (if needed)

In `scraper.rb`, near the middle of the file, there are some simple CSS selectors:

```ruby
channel_selector       = ".tv-guide-channel, [data-test='channel']"
channel_name_selector  = ".tv-guide-channel__name, h2"
program_row_selector   = ".tv-guide-program, [data-test='program']"
program_time_selector  = ".tv-guide-program__time, .time"
program_title_selector = ".tv-guide-program__title, .title"
```

If DR changes the HTML, open the TV guide page in your browser, right-click on
the elements (channel name, time, title), click **Inspect**, and adjust these
selectors to match the actual classes/attributes you see.


