# Delay Repay Automation

You're a season ticket holder. You've paid a large sum of money to Thameslink for unlimited travel for a week, month, or a year.

Your train is late. Again.

Set this thing up so that filling in the delay repay form isn't such a pain the next time you're held up. By the time you get off the train, you've had enough of your time wasted.

**This has only been tested on OS X (Yosemite), and only supports season tickets (of any length).**

## Setup on OS X

Make sure you have Firefox installed: <https://www.mozilla.org/en-GB/firefox/new/>

Make sure you have Git installed: <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>

Make sure you have a [GitHub](https://github.com) account - you'll be asked for your credentials if you don't already use Git.

Make sure you have a picture of your season ticket.

Open the Terminal app. If you're not sure how to do that, use Spotlight by pressing `cmd`+`Space` and start typing 'Terminal'.

Enter the following commands:

```
cd ~/Documents
git clone https://github.com/olethalai/delay_repay_automation.git
sudo gem install selenium-webdriver
cd delay_repay_automation
open .
```

A Finder window will have opened. Drag your picture of your season ticket into the open folder.

Now go back to Terminal, and run:

```
ruby thameslink.rb
```

When you enter a command starting with `sudo`, you'll be asked for the password to your Mac.

The first time you run `ruby thameslink.rb`, a text file should open. Fill it out with information about yourself, and save it..

Run `ruby thameslink.rb` again. Another text file will open. Fill it out with information about your ticket. These are the same pieces of information that the delay repay form asks for. The [delay repay form](http://www.thameslinkrailway.com/contact-us/delay-repay/claim-form/) has a guide for finding the numbers for the light blue and dark blue boxes when you select your ticket type. Save.

Run `ruby thameslink.rb` a third time. This time it should open Firefox and whizz through the form.

All you have to do now is check the date (it'll be today's date by default) and enter the details of your delayed journey. Then, scroll down to the Captcha, verify that you're not a robot and wait for your National Rail voucher. :)

If/when it doesn't work for you, and you're on a Mac, and you're a season ticket holder, please leave a comment to let me know something went wrong.
