# リリース時に使ういろんなメモ。

# アイコン

http://www.flaticon.com/

# アプリの名前

* 日本語
ことせかい: 小説家になろう読み上げアプリ

* 英語
NovelSpeaker: "Let's become a novelist" reading aloud application

# アプリの説明

小説家になろう で公開されている小説を読み上げるアプリです。
歩いている時や家事をしている時などに小説を "聞く" ことができます。
バックグラウンド再生に対応していますので、iPhone で他の作業をしながらでも小説を聞き続ける事ができます。

「ことせかい」という名前は、小説家になろうの小説を iPhone の読み上げさせてみたときに、
「異世界」を「ことせかい」と発音したことから来ています。
ということで、残念ながら現在アプリから使える読み上げ機能では異世界のような単語を間違えて読むことが案外多いです。
そのような場合を少しでも軽減させるために読み替えの機能もつけてありますが、あまり期待しないでください。(´・ω・`)

使い方：
「なろう検索」で小説家になろうのサイトから読みたい小説を検索して、右上のdownloadボタンでダウンロードを開始させます。
ダウンロード中のものも「本棚」に登録されますので、ダウンロードの終わったものを選択して、右上の「Speak」を選択することで読み上げを開始します。

読み上げ開始位置を指定したい場合は、一旦読み上げを停止させて、読み上げを開始させたい位置を長押しして選択状態にしてから「Speak」ボタンを押す事で指定できます。
読み上げ位置は小説ごとに保存されます。


設定項目について

読み上げ速度などの変更方法：
「設定」タブの「声質の設定」から通常時の読み上げ設定(声質と速度)、会話文の時の設定(声質のみ)が、
「読みの修正」から「異世界」を「ことせかい」と読み上げさせないための設定ができます。
ただ、「読みの修正」に大量に修正項目を設定すると読み上げ開始時に結構かなりいっぱい待たされるようになります。すみません。

表示文字の大きさ：
「設定」タブの「表示文字サイズの設定」から、小説本文の表示に使われる文字の大きさを指定できます。

読み上げ時の間の設定：
「設定」タブの「読上げ時の間の設定」から、句読点や三点リーダーなどといったものについて、読み上げ時に間を開ける設定が可能です。

再生の自動停止：
「設定」タブの「最大連続再生時間」の項目で、再生を開始した後に自動的に停止するまでの時間を設定できます。標準では23時間55分になっていますので、概ね停止せずに読み上げがなされるように見えるはずです。

注意：
バックグラウンドで再生を行っている場合、画面が消えていたとしてもバッテリーの消費が増えますのでご注意ください。

小説のダウンロードが失敗してしまった場合：
小説家になろうのサイトが高負荷になっていたり、Web認証の必要なWiFi接続を行っている時などに小説をダウンロードした場合、小説ではない文字列が読み込まれることがあります。その場合は、ホームボタン二度押しで出てくるマルチタスク画面にて ことせかい を終了させて、再度起動の後、本棚メニューの右上にある矢印が回転しているボタンを押して再読み込みをさせてください。しばらく待つと再読み込みが読み込みが終わり、その後であれば正しい小説が読み込めているはずです。

高度な使い方：
* URLスキームによる小説のダウンロード
URLスキーム novelspeaker://downloadncode/ncode-ncode-ncode... という形式で ncode を指定することで、対象の小説をダウンロードキューに追加する事ができます。ncode とは、小説家になろうでの個々の小説のIDで、小説のページのURL(例えば http://ncode.syosetu.com/n0537ci/)の最後の部分(この例の場合は n0537ci)です。URLスキームでは ncode-ncode-ncode... と、複数の ncode を - (ハイフン) を使って繋げて記述できます。パソコン等で読んでいる小説を ことせかい でも読もうと思った時にこのURLスキームをiPhoneに送信して開くことでダウンロードを楽にできるようになる…… かもしれません。(単にアプリ内で検索してもいいような気がしますが)
なお、「設定」タブの「再ダウンロード用URLの取得」を用いることで、本棚に登録されている小説についてのダウンロードリストを取得することができます。機種変更をする時などにご利用ください。

* 自作小説の登録
設定タブの下の方の「新規自作小説の追加」を選択することで、自分で書いた文章を小説としてことせかいに登録することができます。
ここで作成した自作小説を再度編集したい場合、自作小説を表示している時に編集ボタン(小説家になろうの小説の場合は「詳細」ボタンがあった位置にあります)を押すことで再度編集できます。
なお、この自作小説の登録機能は、ちょっと汚い形で組み込んでしまっているので、今後のアップデートでもう少し違った形(EPUB形式での取り込みとか)での実装に変更するかもしれません。その場合はもしかすると自作小説自体を新形式に移行出来ない可能性があります(できるだけ残そうと努力はするつもりですけれども)。もしそうなってしまった場合はご容赦お願いしつつ、自作小説は別途バックアップを取っておいていただきますようお願い致します。

小説のダウンロードが失敗してしまった場合：
小説家になろうのサイトが高負荷になっていたり、Web認証の必要なWiFi接続を行っている時などに小説をダウンロードした場合、小説ではない文字列が読み込まれることがあります。その場合は、ホームボタン二度押しで出てくるマルチタスク画面にて ことせかい を終了させて、再度起動の後、本棚メニューの右上にある矢印が回転しているボタンを押して再読み込みをさせてください。しばらく待つと再読み込みが読み込みが終わり、その後であれば正しい小説が読み込めているはずです。

起動時に落ちてしまう場合：
アップデート後、起動時に落ちてしまう場合には、誠に申し訳ありませんが一旦アプリを削除してから、もう一度インストールすることで起動するようになります。ただ、アンインストールしてしまうとダウンロードした小説や読み替え辞書などの情報が全て消えてしまいます。すみません。


「小説家になろう」は株式会社ヒナプロジェクト様の登録商標です。
本アプリは株式会社ヒナプロジェクト様が提供するものではありません。

* 英語
NovelSpeaker is application to read the shown novel which is "Let's become a novelist" aloud.
"listen" hears a novel when I do walking time and housework.
Because I cope with background reproduction, I can continue hearing a novel even when carrying out other activities with iPhone.


# キーワード

* 日本語
小説家になろう, 読み上げ, 小説, なろう

* 英語
Let's become a novelist, novel, reading aloud

# サポートURL

http://limura.github.io/NovelSpeaker



# github pages で Autogenerate したら出てきたのでメモ

### Welcome to GitHub Pages.
This automatic page generator is the easiest way to create beautiful pages for all of your projects. Author your page content here using GitHub Flavored Markdown, select a template crafted by a designer, and publish. After your page is generated, you can check out the new branch:

```
$ cd your_repo_root/repo_name
$ git fetch origin
$ git checkout gh-pages
```

If you're using the GitHub for Mac, simply sync your repository and you'll see the new branch.

### Designer Templates
We've crafted some handsome templates for you to use. Go ahead and continue to layouts to browse through them. You can easily go back to edit your page before publishing. After publishing your page, you can revisit the page generator and switch to another theme. Your Page content will be preserved if it remained markdown format.

### Rather Drive Stick?
If you prefer to not use the automatic generator, push a branch named `gh-pages` to your repository to create a page manually. In addition to supporting regular HTML content, GitHub Pages support Jekyll, a simple, blog aware static site generator written by our own Tom Preston-Werner. Jekyll makes it easy to create site-wide headers and footers without having to copy them across every page. It also offers intelligent blog support and other advanced templating features.

### Authors and Contributors
You can @mention a GitHub username to generate a link to their profile. The resulting `<a>` element will link to the contributor's GitHub Profile. For example: In 2007, Chris Wanstrath (@defunkt), PJ Hyett (@pjhyett), and Tom Preston-Werner (@mojombo) founded GitHub.

### Support or Contact
Having trouble with Pages? Check out the documentation at http://help.github.com/pages or contact support@github.com and we’ll help you sort it out.




# Ver 1.0.2 リリースノート

インタフェースの変更
・小説を読んでいる画面で前と後の章への移動用にボタンをつけました。左右フリックでの移動はできなくなります。

問題の修正
・リロードした最新のものがダウンロードできなかった問題を修正
・バックグラウンド再生中に章を移動した時、再生が停止する可能性があった問題を修正
・小説の表示がステータスバーやナビゲーションバーにかぶって表示されて見えなくなることがある問題を修正
・読み替えの設定を増やすと再生開始や章の切り替わり時に長時間無反応になる問題を"ある程度"修正。(件数が増えれば遅くはなります)
・大量の小説をダウンロードした状態だと動作が遅くなっていた問題を修正

# Version 1.0.2 release note

Change of the interface

- I attached a button for the front and the movement to a later chapter with the screen which read a novel. By the right and left flick cannot move now.

Correction of the problem

- I revise the problem that the latest thing which I reloaded was not able to download.
- When I moved a chapter during background reproduction, I revise the problem that reproduction might stop.
- I revise the problem that the indication of the novel is fogged in a status bar and navigation bar, and it may not seem that it is displayed.
- I revise a reproduction start and the problem that I am replaced, and nothing sometimes reacts to for a long time of the chapter when I increase the setting of the reading substitute. (if the number increases, it becomes late)
- Movement revises the problem that became slow if in condition to have downloaded a large quantity of novels.

# Ver 1.1 リリースノート

インタフェースの変更
・本棚、なろう検索、ダウンロード状態 のアイコンを変更しました。
・小説の表示用の文字サイズを変更できるようにしました。「設定」に項目が増えます。
・iPadでも表示できるようにしました(ユニバーサルアプリとなります)。
・読み上げ中に最後の章を読みきった時に、「読み上げが最後に達しました」とアナウンスするようになります。
・起動時に最後に読んでいた小説を表示するようになります。
・最大連続再生時間の指定を設定ページに入れました。標準では23時間55分になっています。再生を開始してから、ここで設定された時間が経つと再生が停止します。
・読み上げ時に「……」や「、」「。」等でも読み上げの間をつけられるような設定項目を設定ページに追加しました。
・小説の詳細ページの作者名を押すと、その作者の小説を検索するようになります。
・小説を読むページにシェアボタンを追加しました。今読んでいるページへのURLやことせかいのアプリへのリンクなどをTwitterやmailでシェアすることができます。
・URLスキーム novelspeaker://downloadncode/ncode-ncode-ncode... という形式で、ncode を指定して小説をダウンロードさせる事ができるようになります。「設定」タブの「再ダウンロード用URLの取得」で本棚に登録されている小説についてのダウンロード用URLを取得できますので、機種変更等の際にご利用ください。

追伸：
レビューありがとうございます。不都合の報告や機能追加などの提案、本当にありがたいです。

読みの修正用の読み替え辞書をサーバにアップロードしてユーザ間で共有する事についてなのですが、サーバの管理が発生する(24時間365日起動し続けているサーバを管理するのはちょっと大変な)のと(無いとは思いますが)意図しない読み替え(例えば「あ」を「くぁｗせｄｒｆｔｇｙふじこ」に読み替えるとか)を行う読み替え辞書の登録がなされた場合の排除方法といった、複数ユーザによる登録にまつわる問題を考えるのが大変そうだなぁ、と思ったのでとりあえず良い案が浮かぶまでは実装はしないことにしました。

読み上げ時の間の設定については、標準の方法ですととても短い「間」の指定が(おそらく)できません。今回のリリースでは非推奨の方式を選択することができるようにすることでいろいろな文字に対しても「間」の設定ができるようにしています。ただ、非推奨の方式は Siriさん の読み上げ方式の穴を突いているような所がありまして、将来的には意図した通りには使えなくなる可能性がありそうです(具体的には指定された間の長さに応じた回数「_。」という文字列を読み上げさせています)。ですので、非推奨型での間の設定の使用はあまりおすすめしないことにしておきます。ご了承ください。

Interface change
- Icon changed.
- Text size change configuration is now on settings page.
- iPad mode. NovelSpeaker is universal application now.
- If reached at the end of a book then announce messsage: "Because it reached at the end of a book, I stopped reading aloud."
- First open view is now "Last read page".
- "Max continuation reproduction time" configuration is now on settings page.
- "Speak wait config" configuration is now on settings page.
- Can search same writer novel, in novel details page.
- Share button added for novel read page.
- Custom URL scheme is now available. It can download with NCODE. Use novelspeaker://downloadncode/ncode-ncode-ncode...
  "ncode" is "Let's become a novelist"'s novel-code. "ncode" can found "Let's become a novelist" web page ( http://syosetu.com ). example ncode found at last of url  like http://ncode.syosetu.com/n9669bk/ (this example include ncode "n9669bk")

# Version 1.1.1

# TODO

- アップデートをダウンロードすると読み上げ位置(栞)が吹き飛んで一番最初になってしまう問題のfix

# リリースノート
インタフェースの変更
・読み上げの間の設定に 0.1刻み で変化させるボタンを追加しました。また、簡単な文を使っての読み上げテストができるようになります。
・小説の詳細ページの右上に、作者のマイページをSafariで表示するためのボタンを追加しました。
・なろう検索のタブで、検索時の順位付けを「総合評価の高い順」などから選べるようにしました。ただ、「検索開始」ボタンが画面外に押し出されてちょっと使いづらくなっています。すみません。

問題の修正
・読み上げの間の設定を「非推奨型」にした場合に文末の単語を2回読み上げる事がある問題を修正
・読み上げ対象の文字列に "@" が含まれている章を選択すると落ちる問題を修正
・読み上げ開始時に読み上げが失敗すると、アプリを落とさないと読み上げができなくなる問題を一部修正(再度再生させようとした時に読み上げられない問題を解決しただけで、読み上げが勝手に停止する問題については直せていません。すみません)

追伸：
評価やレビュー、ありがとうございます。回避方法がなく落ちてしまう不都合の報告がありましたので、主に不都合対応のリリースをさせていただきます。
その他、提案していただいた機能で、簡単に追加できそうなものについては追加してみました。ご確認ください。

本棚周り、コピー＆ペーストでの新規本の登録、他サイトの小説の読み込み等は実装するのに結構時間がかかりますので今回のリリースには含めることができませんでした。すみません。なお、これらの対応については結構かなりいっぱいたくさん時間がかかってしまいそうですので、気長に待っていただければ嬉しいです。



# Version 1.1.1 release note
Interface update
- "Speak wait config" page inploved.
- "Go to writer page" button added at novel detail page.

Bug fix
- Duplicate word speech about "Experimental" speak setting is fixed.
- I revise a problem to come off when I choose the chapter which "@" is included in for character string for the reading aloud.
- Speech start fail bug fixed.

# レビュー用メモ

修正項目以下の通りです。

Change of the interface

- I attached a button for the front and the movement to a later chapter with the screen which read a novel. By the right and left flick cannot move now.

Correction of the problem

- I revise the problem that the latest thing which I reloaded was not able to download.
- When I moved a chapter during background reproduction, I revise the problem that reproduction might stop.
- I revise the problem that the indication of the novel is fogged in a status bar and navigation bar, and it may not seem that it is displayed.
- I revise a reproduction start and the problem that I am replaced, and nothing sometimes reacts to for a long time of the chapter when I increase the setting of the reading substitute. (if the number increases, it becomes late)


# Ver 1.1.2

インタフェースの変更

・なろう検索のタブで、検索時の順位付けの部分を、タップしてから選択するタイプに変更しました。(検索開始ボタンがスクロールしないと見えない状態だったのを解消しました)
・設定タブに更新履歴の情報を追加しました。
・アプリの更新があった時に、一回だけダイアログを表示するようにしました。

追伸：
評価やレビュー、ありがとうございます。今回はほとんど更新はありません。
やはり、検索タブの所の PickerView(検索の順位付けのくるくる回るUI)が入ってしまって「検索開始」ボタンが見えなくなってしまっていて、スクロールしないと駄目になっていたのが原因(?)で検索出来ない人がおられるようでしたので、ちょっとUIを変えました。
あと、ことせかいをアップデートしたのが気づいてもらえないかもしれないなぁ、と思って、バージョン番号が変わった時には一回だけダイアログを出すようにしました。ということで、ちょっとウザくなってしまいます。すみません。

# Version 1.1.2

Interface change

- in Search tab, "Search order" is now show after tap.
- Add "Update log" in Settings tab.
- Update Notice dialog added. This is displayed first time only.


# Ver 1.1.3

問題の修正

・なろう検索のタブで、検索用文字列を入力できなくなっていた問題を修正しました。

追伸：
評価やレビュー、ありがとうございます。今回は検索が無意味になってしまうようなバグを入れたままリリースしてしまって申し訳ありませんでした。
焦って提出して安心したままじゃ駄目ですね…… 本当にすみませんでした。

# Version 1.1.3

Bug fix

- in Search tab, Search string is now can editable.


# Ver 1.1.4

インタフェースの変更

・文章上で長押しした時に出るメニューに、「読み替え辞書へ登録」を追加しました。コピーしてペーストする手間が少しだけ減ります。
・設定タブの下の方に「新規自作小説の追加」が増えます。自分で書いた文章を読み上げさせる時などにご利用ください。
作成した自作小説を再度編集したい場合、自作小説を表示している時に編集ボタン(小説家になろうの小説の場合は「詳細」ボタンがあった位置にあります)を押すことで再度編集できます。
なお、この自作小説の登録機能は、ちょっと汚い形で組み込んでしまったので、今後のアップデートでもう少し違った形での実装に変更するかもしれません。その場合はもしかすると自作小説自体を新形式に移行出来ない可能性があります(できるだけ残そうと努力はするつもりですけれども)。もしそうなってしまった場合はご容赦お願いしつつ、自作小説は別途バックアップを取っておいていただきますようお願い致します。

問題の修正

・読み上げが勝手に停止する問題を修正しました(多分これで根本的な対応になると思います)

追伸
評価やレビュー、ありがとうございます。長いことおまたせしてしまって申し訳ありません。自作小説の登録機能を追加してみました。自作小説だけでなく、小説家になろう以外の小説を読み上げさせることもできるようになったかと思います。ただ、小説家になろう以外からの小説を読み込ませる機能、と考えるとちょっと面倒臭いと思われるので、もう少し楽に登録できる方法(EPUBを読み込みとか)を考察中です。
それでは、今後とも ことせかい をよろしくお願い致します。


# Version 1.1.4

Interface change

- Add "Add default correction of the reading" menu on text long tap menu.
- Add "Add own created book" feature at Settings page. You can write yourself book now!

Bug fix.

- Reading aloud revises a problem to stop without permission.



# Ver 1.1.5

インタフェースの変更

・iOS 9 以上で、発音される音声データを選択できるようになります。設定タブの声質の設定に項目が増えます。
利用可能な音声データは初期状態では一つだけですので、音声データを増やしたい場合は
設定アプリ > 一般 > アクセシビリティ > スピーチ > 声 > 日本語
と手繰っていった所で音声データをダウンロードしてください。
(なお、Siriさんの音声データは O-ren(拡張) という名前になっているもののようです）
・Voice Over が有効になっている場合、読み上げ開始時に警告を発するようになります。
・本棚の並び順を変更できるようになります。本棚タブの右上にボタンが増えます。
・小説の更新分を自動で取得させることができるようになります。設定タブに設定項目が増えます。

問題の修正

・小説の更新分を読み込むなどをした時に、読み上げ位置が初期化される問題を修正
・電話がかかってきた時など、ことせかい 以外のアプリで音が使われる時に再生を停止しなかった問題を修正
・アプリ名が NovelSpeaker になっていたのを ことせかい になるように修正
・iPhone 6 Plus 等で上下に黒帯が入る事がある問題を修正
・内部DBへのアクセス時に落ちる問題を修正

追伸

評価やレビュー、ありがとうございます。かなり長いこと放置してしまっていてすみません。iOS 10 になって標準の音声データがしょぼくなりすぎたのを受けて、取り急ぎ標準の音声以外のデータを使えるようにしたものに更新致します。これで本物のSiriさんに読み上げてもらえるようになるはずです。ただ、これが出来るのに気づいたのが手元の端末を iOS 10 に上げた後でなので、iOS 9 では試しておらず、もしかすると利用できないかもしれません(なお、iOS 8 ではAppleの提供しているAPIに音声選択の項目が無いため利用できません)。もし、問題がありましたら恐れ入りますが最新の iOS へ更新するなどで対応していただけるとうれしいです。
なお、次回以降の更新時の話になりますが、ことせかい の対応OSバージョンを iOS 8 以上にすることを計画しています(現在は iOS 7 以上の対応です)。どうしても iOS 7 で動作して欲しいという方がおられましたら、サポートサイトの下の方に用意致しましたご意見ご要望フォームから思いの丈を送っていただけると対応できるようになるかもしれません。
それでは、今後とも ことせかい をよろしくお願い致します。

# Version 1.1.5

Interface change

- Can select speaker data. You need download sepaker data from:
  Settings > General > Accessibility > Speech > Voices > Japanese
- If VoiceOver enabled, alert dialog is open when speak start.
- Bookshelf sort type selector now available.
- Auto download for updated novel mode added. Add enable/disable this mode settings at Settings page.

Bug fix

- I read it aloud at the time of the re-reading of the novel, and a position revised an initialized problem.
- When it had a telephone, It come to stop reproduction.
- I revise the problem that a black belt holder may begin up and down in 6 iPhone Plus.
- Application revised a bug to be finished at the time of access to internal DB.

metadata rejected に返信した奴
"AAA"という単語はサイト名です。"AAA"は http://syosetu.com/ というWebサイトの名前です。

本アプリは”AAA"にある小説を読み上げるためのものです。従って、ユーザは”AAA"という単語で検索をすることが有り得ます。そのため、我々はメタデータには”AAA"が含まれるべきだと考えています。

メタデータ”AAA"はこのまま残しておいて良いでしょうか？

アプリ名については日本語の言い回し上紛らわしい事を確認致しましたので”BBB"と修正致します。

The word "小説家になろう" is the site name. "小説家になろう" is the name of the Web site called http://syosetu.com/.

This application is intended to read a novel in "小説家になろう" aloud. Therefore, the user may have that I search it by a word "小説家になろう". Therefore we think that "小説家になろう" should be included in meta data.

May meta data "小説家になろう" leave it as it is?

Because I confirmed a confusing thing in a Japanese expression about the application name, I make modifications with "ことせかい".

# Ver 1.1.6

インタフェースの変更

- 再生中にイヤホンジャックからイヤホンが引き抜かれた場合、再生が停止するようになります

問題の修正

- 「なろう検索」からのダウンロード等が失敗する問題を修正
- ある本の読み上げを停止した後、別の本を開いて読み上げを開始しようとした時に、読み上げ開始位置が先程停止した読み上げ位置にズレてしまう問題を修正
- 連続再生時間で指定した時間が経つ前にページ切り替えが起こると連続再生時間での自動停止が効かなくなる問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。また、小説家になろう様側の仕様変更でダウンロードができなくなるという不都合でご迷惑とご心配をおかけしましたことをお詫びいたします。これからも宜しくお願い致します。
今回は小説家になろうのサイトのメンテナンス以降、ダウンロードができなくなってしまった問題への対応が主となります。
また、作りかけの機能も一応入っているのですが、この作りかけの機能については使い勝手があんまりよくないのと、"表示されているページを読み込む"ために混乱を招く形式になっていると思いますので、分かる人だけ使ってくださいといった形で提供致します。ですので、この機能については将来的には別の形で実装しなおす可能性があります(特にUI周りは変えたいと思っているので「こうしたらもっと使いやすいor混乱しにくいんじゃないか？」といった提案等はお気軽にサポートサイト側のご意見ご要望フォームにお送りください)。また、リリース後に出てくるダイアログでは言及せず、AppStore側でのアップデートノートを読んだ人だけが気づける機能としています。機能の説明としては、

- Safariで利用できるシェアボタン(上向きの矢印のボタン)から利用できる「ことせかいへ読み込む」機能を追加しました。Safariで "小説の本文が表示されている状態"(小説のタイトルページではなくて本文が表示されているページです) で、シェアボタン(四角から上向きの矢印が出ているボタン)を押して、「ことせかいへ読み込む」を選択すると利用できます。(OFFになっていて表示されていない場合には、シェアボタンを押した後、「その他」の中で「ことせかいへ読み込む」をONにしてからご利用ください)

という物になります。なお、この「ことせかいへ読み込む」機能は、Webページを取り込む時の補佐、程度の性能となっております。複数ページがある場合には続きのページも出来る限り読み込むようにはしましたが、全てのWebページで動作するようには作られておりませんし、本来は続きのページでない記事などを続きのページと誤認して読み込んでしまったりすることもあるようなものなので、あまり期待せずに うまく動いたらラッキー、位で思っておいていただけると嬉しいです(実際、いくつかのWebサイトでは動かないのを確認しています。その場合はお手数ですが今まで通りコピーしてから自作小説としてペーストするなどで対応していただければ嬉しいです。なお、サポートサイト側などから「このサイト(できればURLまで書いていただけるとありがたいです)がうまく動きませんでした」と報告していただけると嬉しいですが、すぐには対応できないかもしれません)。また、読み込まれた文章に本文と関係の無いもの(例えば「次のページへ」のリンクの文字など)が混じることが結構あります。そのため、これらを修正できるように、Webページから読み込まれた文章は自作小説と同じ扱いをしていますので、編集して取り除いて頂ければと思います。

次に、「********」といった文字がある文章を読み上げさせようとすると高確率でアプリが終了してしまうという問題を確認しています。原因を究明中なのですが、開明には至っていません。一応、例に上げた「*******」というものであれば「*」という文字列を「　」(全角スペース)として読み替え辞書に登録することでアプリが終了するという問題からは回避できることが確認できていますので、この問題が起きた時にはそのような手法で回避して頂ければと思います。

また、今回のアップデートから ことせかい の対応OSバージョンを iOS 8 以上に致しました。ダウンロードできている方には問題ないと思いますが、古い iOS を利用している場合にはアップデートはできなくなっているものと思われます。

それでは、今後とも ことせかい を宜しくお願い致します。


# Version 1.1.6

Interface change

- When an headphone is pulled up when an headphone sticks in headphone Jack, speech comes to stop.

Bug fix

- Fixed problem that download from Let's becom novelist site failed.
- Fixed a problem in which the reading start position shifted to the reading position stopped earlier when reading of a book was stopped and when opening another book and starting reading aloud.
- Fixed a problem that automatic stop at continuous playback time does not work if page switching occurs before the specified time in continuous playback time.


レビュワー向け

Interface change

- When an headphone is pulled up when an headphone sticks in headphone Jack, speech comes to stop.
- Add "download with NovelSpeaker" Action Extension for Safari. It's use http://* connection.

Bug fix

- Fixed problem that download from Let's becom novelist site failed.
- Fixed a problem in which the reading start position shifted to the reading position stopped earlier when reading of a book was stopped and when opening another book and starting reading aloud.
- Fixed a problem that automatic stop at continuous playback time does not work if page switching occurs before the specified time in continuous playback time.

レビュワー向け reject された後の追記

I updated the App Archive because Metadata is wrong.

> We noticed the app icon displayed on the device and the large icon displayed on the App Store do not sufficiently match, which makes it difficult for users to find the app they just downloaded.

However, in this explanation, I was not sure what exactly is wrong.
I did not know whether the color of the application icon is a problem or whether the size is a problem.
In the Xcode project, the icon of the part of the image to be attached will be blank, so it will correspond to newly setting 1024px.
If there is still a problem, I am glad that you can specifically tell me what is the problem.

----
In japanese.
Metadataがおかしいという事で、App Archiveを更新しました。

> We noticed the app icon displayed on the device and the large icon displayed on the App Store do not sufficiently match, which makes it difficult for users to find the app they just downloaded.

しかし、この説明では具体的に何がおかしいのかがよくわかりませんでした。
アプリアイコンの色が問題なのか、大きさが問題なのかがわかりませんでした。
Xcode projectでは、添付致します画像の部分のアイコンが空白でしたので、新たに1024pxのものを設定した、という対応になります。
まだ問題があるのであれば、具体的に、何が問題なのかを指示していただけると嬉しいです。


# Ver 1.1.7

インタフェースの変更

・設定タブに、「ルビをルビだけ読むようにする」のON/OFF設定を追加
・「設定」->「再ダウンロード用URLの取得」、を「再ダウンロード用データの生成」に変更します。小説家になろうのものだけでなく、自作小説、Safariから ことせかい に読み込ませたもの、読みの修正用辞書のバックアップが可能となります
・Safari から「ことせかい に読み込む」機能を使って読み込ませた時、タイトルが確定した時点でタイトルをダイアログで表示するようになります

問題の修正

・小説を読み上げ中に設定タブなどへ移動して戻ってくると、読み上げ位置が過去のものに戻されてしまう問題を修正
・全ての小説を再ダウンロードする時に、更新が無いものについてはダウンロードキューに追加しないようになります

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正は細かい改良やバグ修正が主となります。
小説の読み上げ中にタブを移動すると読み上げ位置が巻き戻る問題はご迷惑をおかけしました。申し訳ありません。
今回は再ダウンロード用のURLの取得機能を変更して、自作小説のバックアップや読みの修正用辞書のバックアップもできるようにしてみました。ファイルの拡張子を .novelspeaker-backup-json にしていだだいて、正しいJSON形式で記述していただければ、外部から読み替え辞書の登録もできるようになります(読み替え辞書のみの記載だけでも問題ありませんので、読み替え辞書を登録するために利用していただいても構いません)。これらのデータは上書き保存されます。古いもので上書きされなかったものは削除されませんのでご注意ください。なお、JSONの形式は一度「再ダウンロード用データの生成」でバックアップ用データを生成して頂いて、その中身を真似る形で理解して頂ければと思います。

それでは、今後とも ことせかい を宜しくお願い致します。

# Ver 1.1.7

Interface change

- Add "Speech ruby only" setting feature on Settings page.
- Change "Create re-download URL" feature to "Create NovelSpeaker Backup file" on Settings page.
- When loading with Safari using the "download with NovelSpeaker" extension, title will be displayed in the dialog when the title is confirmed.

Bug fix

- Fixed a problem that when you move to the setting tab etc. while reading a novel and return it, the reading-out position is returned to the past one.
- When all the novels are re-downloaded, those that do not update will not be added to the download queue.


Appleのレビュアー向けの補足情報


In this update, files with the file extension .novelspeaker-backup-json are associated with the application.
This function is intended for backup purposes of downloaded novels etc.
This file is generated using "Create re-download URL" in SettingsPage of the application.
The user can download the generated novelspeaker-backup-json file into the application, and you can re-download the backed up novel again.

.novelspeaker-backup-json The contents of the file are in JSON format and are roughly as follows.

{
  "data_version" : "1.0.0",
  "word_replacement_dictionary": {
    "from word": "to word", ...
  },
  "bookshelf": [
  {
    "type": "url" or "ncode" or "user",
    "ncode": ..., "title": ..., "id": ..., ...
  }, ...
  ]
}

In the above. Novelskeaker-backup-json, a place to save data using encryption has been added.
For that reason, we decided to use the encryption function "Yes" when submitting the review of the application.
This encryption function uses sha 256 (CC_SHA 256 () function) prepared by OS side.



# Ver 1.1.8

インタフェースの変更

・設定タブのUIを少し作り直し(機能は変わりません)
・設定タブの「ルビをルビだけ読むようにする」をONにした時に、ルビとして認識しない文字を指定できるように
・設定タブの読みの修正内にて、修正項目の検索ができるように

問題の修正

・iPhone SE等の画面の小さい端末で、文字が見切れていた問題を一部修正
・「ルビをルビだけ読むようにする」機能で、ルビ以外の部分を読み飛ばしてしまう問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正も細かい改良やバグ修正が主となります。
設定タブで文字が見切れていた問題やルビをルビだけ読むようにする機能の不都合は気づいておりませんでした。皆様からの不都合報告には重ねてお礼申し上げます。
今回のバージョンから、UI周りを外部のライブラリに変更して作り直していっています。以前と動作が少し異なる所も出てきてしまうと思いますが、機能的には同じものを提供できるようにしているつもりです。何か問題などありましたらお気軽にご意見ご要望フォーム等から指摘して頂けると嬉しいです。

それでは、今後とも ことせかい をよろしくお願いいたします。


# Ver 1.1.8

Interface change

- Redo some UI of setting tab (function does not change)
- To enable you to designate characters that you do not recognize as ruby when turning on "Speech ruby only" on setting tab
- In order to search for correction items within correction of reading on setting tab

- bug fix

- Fixed a part of the problem that letters were not seen on small terminal of screen of iPhone SE etc
- Fixed a problem that "Speech ruby only" skipping skipping parts other than ruby


# Ver 1.1.9

問題の修正

・新規ユーザー小説の登録が必ず失敗するようになっていた問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回はバグ修正のみの更新になります。
新規UIに変更したあたりでバグを作り込んでいました。申し訳ありません。

今後とも ことせかい をよろしくお願いいたします。

# Ver 1.1.9

bug fix

- Fixed an issue where registration of new user novels always failed.

# Ver 1.1.10

インタフェースの変更

・「ダウンロード状態」タブを潰して「Web取込」タブを新設。Web取込では表示されているWebPageの文字を取り込む事ができるようになるはずです。使い方の詳しい説明はサポートサイトを参照してください
・Safariから取り込む 機能でも、タイトルや内容を確認してから取り込む事ができるように
・小説を読んでいる画面にて、左右へのスワイプで章の切り替えができるように

問題の修正

・小説のタイトルやあらすじに&quot;等があった時にそのまま表示されてしまっていた問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回は「Web取込」機能のリリースが主たる目的の更新となります。この機能は少し前から使えるようになっていた、Safariで表示しているWebページを取り込む機能を少し使いやすくしようとしたものです。大まかな使い方としては、

1. Web取込タブに内蔵されているWebブラウザで、ことせかい に取り込みたい小説を表示させる
2. 右下にある「取り込み」ボタンを押す
3. そのページを取り込むとどのような内容となるのかがダイアログで表示されるので、確認の上「このまま取り込む」ボタンを押す事で取り込みを開始する

という形になります。なお、3. のシーンで「続ページ：有り」となっている場合、複数ページに分かれている文書を最大100ページまで読み込みます(それ以降は本棚ページでリロードボタンを押す事でダウンロードを続行します)。
より詳しい使い方をサポートサイト側に書いておきますのでそちらもご参照ください。

また、このWeb取込の機能は個々のWebページ毎に「本文」「タイトル」「作者名」「続くページへのリンク」等といった情報を取り出す必要があるため、それらの情報をデータベース化して利用しています。という事で、この情報が登録されていないWebサイトでは取り込みがうまく動かない事になるため、このデータベースの内容が充実していないと寂しい事になるわけです。ただ、世の中には沢山のWebサイトがあり、それに対して ことせかい の開発者は一人ですので正直全く人手が足りません。ですので、このデータベースのメンテナンスを手伝って頂ける方を募集します(なお、お手伝い頂いても報酬は何も出ません事をご承知ください)。データベースのメンテナンスについての詳しい情報も使い方同様にサポートサイト側に書いておきますのでお手伝いして頂ける方はぜひお手伝いをお願いします。

また、次回以降のアップデート時に、対応の iOS バージョンを 9 (か、もしかすると10) 以上にしたいと考えています。iOS のバージョンが古いもので動かしているなどで、対応バージョンの上昇が困るという方がおられましたら、サポートサイト側のご意見ご要望フォーム等からお知らせして頂ければ、対応バージョンを上げないような努力をしてみようと考えます。逆に言うと、お知らせ頂けなければ気兼ねなく対応の iOS バージョンを上げてしまうと思われますので、重ねて申し上げますが、上げてほしくない方がおられましたらお知らせください。

それでは、今後とも ことせかい をよろしくお願いいたします。


# Ver 1.1.10

Interface change

- New Web Import tab added.
- Even for functions to be imported from Safari, you can check the title and contents and then import it.
- On the screen reading the novel, let's switch chapters with swipe left and right.

bug fix

- Fixed problem which was displayed as it was when &quot; etc was in the title and the outline of the novel.

# Version 1.1.11

インタフェースの変更

・Web取込タブにて、Googleのような検索サイトへのアクセスを閉じました(「無制限のWebアクセス」によるレーティング17+を回避する方策です)

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

さて、今回の修正はちょっと残念な修正になります。Version 1.1.10 にした時に追加した Web取込 タブなのですが、これは所謂普通のWebブラウザのようなものとして実装されていました。この場合、Apple側に提出する年齢制限指定の部分にある「無制限のWebアクセス」をONにしないといけないのですが、これをONにしてしまうとアプリのレーティングが17+になります。ということで Version 1.1.10 はレーティングが 9+ から 17+ になってしまいました。
当方、年齢制限をされている人が使っておられることを完全に失念しておりましたので、特に何の警告もなく、レーティングを上げた状態でリリース致しました。
なのですが、おそらくはこの変更によって年齢制限に引っかかってしまった利用者の方から残念だというレビューがつきまして、なるほど使いたい方が使えないのは寂しいなぁということで、少し知恵を絞ってこんな形ならどうだろう、というリリースとなります。

変更箇所は

- Web取込タブのURLバーへのURLや検索文字列の入力をできなくした
- Web取込タブのホームページ(ブックマークリスト)の標準値に設定してある Google へのリンクを削除した

という二点となります。つまり、通常の方法ではGoogle検索のようなものに移動できなくなりますので、アプリ側では「無制限のWebアクセス」ができないという事になる……という目論見です(この状態でリリースされているということはおそらくはその解釈で良いということでしょう)。

で、です。Google検索が使えないと初期値以外のWebサイトを読み込めないじゃないか、というお話があると思います。その場合はお手数ですが Safari 経由で ことせかい を呼び出す機能がありますので、そちらをお使い頂ければと思います。
使い方としては、

- Safari アプリを起動
- ことせかい に取り込みたい本文が表示されている状態にする
- シェアボタン(四角から上向き矢印が出ているボタン)を押し、下段(白黒のアイコンが並んでいる所)にある「ことせかい へ読み込む」を選択して ことせかい へ取り込む(「ことせかい へ読み込む」ボタンが無い場合は右にスクロールしていって「その他」を押し、「ことせかい へ読み込む」をONにしてください)

で、任意のWebページを取り込むことができます。
アプリひとつで完結している方が煩雑さは少なくなるのはわかるのですが、小説を楽しもうと思っている年齢制限に引っかかってしまう方のために、少し涙を飲んで頂ければと思います。

ということで、一応回避策は無い事は無いのですが、使い勝手が悪くなることは否めません。ということで、「やっぱりWeb取込タブでGoogle検索したい！17+で使えない人は涙を飲んでくれ！」という熱い思いを唱える方がおられましたら、その熱い思いをご意見ご要望フォームにぶつけていただければと思います。その熱い思いによっては Version 1.1.10 の形式に戻すことも吝かではありません。なお、返信用のe-mailアドレスを書いておいて頂けると、何らかの対策的なお話ができるかもしれません。

また、余談ですが Version 1.1.10 からはバックアップデータを生成していただくと、ブックマークもバックアップされるようになっています。バックアップされたデータを ことせかい に読み込ませることで、バックアップされたブックマークで ことせかい のブックマークを上書きすることができます。以上余談でした。

また、次回以降のアップデート時に、対応の iOS バージョンを 9 以上にしたいと考えています(お一方 iOSバージョン 10 は勘弁してくださいとの投書がありましたので少なくともこの先1年位は上げても 9 までにする予定です)。iOS のバージョンが古いもので動かしているなどで、対応バージョンの上昇が困るという方がおられましたら、サポートサイト側のご意見ご要望フォーム等からお知らせして頂ければ、対応バージョンを上げないような努力をしてみようと考えます。逆に言うと、お知らせ頂けなければ気兼ねなく対応の iOS バージョンを上げてしまうと思われますので、重ねて申し上げますが、上げてほしくない方がおられましたらお知らせください。

それでは、今後とも ことせかい をよろしくお願いいたします。


# Version 1.1.11

Interface change

- We closed access to the search site like Google on the Web import tab (a way to avoid Rating 17+ by 'Unlimited Web Access')


for review

In this update, we made an update aimed at removing "unrestricted web access" specified by age restriction.
I am cited below as to what I fixed.

- Invalid entry of URL and search string into URL bar of "Web import" tab.
- Deleted the link to Google set to the standard value of the homepage (bookmark list) of "Web import" tab.

With the above fixes, you can not enter URL, Google search, etc from "Web import" tab. Therefore, we think that it will become possible to browse only the site saved as the initial value.
We believe that this means that it can not be said as "unlimited Web access".
I made the above fix, but please let me know what is the problem if I can not remove "unrestricted web access" with this.


# Version 1.1.12

インタフェースの変更

- ユーザ自作小説等を編集しようとした時に、読み上げ位置から編集が開始されるように変更

問題の修正

- iPhone X で本の内容の表示の最初の1,2行が隠れてしまう問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回は細かい修正のみのリリースとなります。iPhone X は当方は所持しておりませんでしたので、ユーザ様からのバグ報告がなければ対応しないといけないと気づけもしませんでしたので、とても助かります。その他にも「これは全然直らないんだけどどうなんだろう……」といった何かは単に気づいていないだけの可能性もありますので、気になる点はお手数ですがサポートサイト側に用意してあります、ご意見ご要望フォームから投稿して頂けるとありがたいです(気づいてはいるけれど実装がまだという物もありますので、github側のissueに同様の項目が無いかどうかを確認してから投稿して頂けますと、とてもありがたいです)。

また、再度のご連絡になりますが、次回以降のアップデート時に、対応の iOS バージョンを 9 以上にしたいと考えています。iOS のバージョンが古いもので動かしているなどで、対応バージョンの上昇が困るという方がおられましたら、サポートサイト側のご意見ご要望フォーム等からお知らせして頂ければ、対応バージョンを上げないような努力をしてみようと考えます。逆に言うと、お知らせ頂けなければ気兼ねなく対応の iOS バージョンを上げてしまうと思われますので、重ねて申し上げますが、上げてほしくない方がおられましたらお知らせください。

それでは、今後とも ことせかい をよろしくお願いいたします。


# Version 1.1.12

Interface change

- When editing a user's own novel etc, change so that editing starts from the reading-out position.

bug fix

- Fixed problem that iPhone X hides the first and second lines of the contents of the book.


# Version 1.1.13

インタフェースの変更

- テキストファイルを自作小説として取り込めるように
- PDFファイルを自作小説として取り込めるように(iOS 11以上のみ)
- 設定タブに「不都合報告をメールで開発者に送る」機能を追加

問題の修正

- Web取込機能で取り込んだ小説について、取り込んだ時間で更新日時を更新するように
- Web取込機能で、HTTP 400 BadRequest でエラーしていた問題の一部を解消

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回はテキストファイルを取り込む事ができるようにしました。SafariからのWebページの取り込みと似ている形で、シェアボタンから利用します。「ことせかいへ読み込む」(アイコンが灰色な)側がSafariからのWebページ取り込みで、「ことせかいにコピー」(アイコンがカラー)のものが今回追加されたテキストファイルの取り込みですのでちょっと混乱する形になっています(どうしたらわかりやすくなりますかね……？)。
テキストファイルが取り込めるようにした仕組みと同じ形で、PDFも取り込めるようにしてみました。ただ、これは iOS 11 から使えるようになった PDFKit というものを使っておりますので、iOS 11 以降でないと動きません。また、PDF の中に書かれている文字列を取り出す仕組みをその PDFKit のものに全ておまかせしておりまして、どうやら二段組のPDF文書などの複雑な構造の文書ですと、めちゃくちゃな内容で取り込まれたりするようです。あと、文字として保存されていないもの(文字が画像として入っている場合等)は取り込めません。なので、PDF取り込み機能はあんまり使い物にならないかもわかりません。
これらのファイル取り込み機能は、シェアボタン経由で「ことせかいにコピー」を選択することで動作します。ただ、SafariとiOS11からのファイルアプリからのシェアボタンでの動作は確認できたのですが、Dropboxアプリからのシェアボタンでは選択肢に出てこないようでした(シェアボタン(エクスポート)->別のアプリで開く->ことせかいへコピー、でなら動くみたいですが、タップ回数が多いですね)。何故そうなるのかの原因がよくわからないので詳しい方がおられましたら教えてください。
また、アプリ内にサポートサイトへのリンクをつけた後あたりから不都合の報告をサポートサイト側から報告して頂ける事が多くなったのですが、残念なことに不都合報告に書かれている情報が少なくて対応できない事が多いです(例えば「しばらく使っていると落ちます」みたいな情報だけですと、何が原因で落ちたのかもわかりませんのでどうにもこうにも対応できません)。開発者の手元で再現のできない問題は再現可能になるような調査を行う必要があり、時間がかかるため、(例に挙げたような)情報量の少ない不都合報告への対応はほぼできないと考えて欲しいです。といっても、再現可能となるような詳細な手順を書いて頂くのも大変だろうというのもわかりますので、ことせかい の操作ログを保存しておいて、不都合報告の時にそれを送信できるようにしてみました。この操作ログと不都合の発生した日時を突き合わせる事で、実際に操作した状況を開発者の手元で再現しやすくなるだろう、という目論見です。ただ、操作ログには ことせかい に取り込んだ小説のURLといった情報も含まれておりますので、この操作ログを送信していただくと、それらの情報が開発者に公開されてしまうことになります。ですので、開発者に知られては困るような情報を ことせかい で扱っている場合には操作ログを送信しないでください(守秘義務的な法律を全然理解していない開発者になりますので、公開されてはいけない情報を扱っている場合は本当に送らないでください。困ります)。なお、アプリが落ちてしまうような時にもログは残るようにしたつもりですので、アプリが落ちた後すぐに操作ログを含めての不都合報告をして頂けると、アプリが落ちた状況も開発者の手元で再現しやすくなりそうです。

以上となります。それでは、これからも ことせかい をよろしくお願い致します。


# Version 1.1.13

Interface change

- Now can import .txt file.
- Now can import .PDF file.
- Add Problem report feature in Settings tab.

Bug fix

- As for the novel imported by the "Web import" function, update the update date and time in the captured time.
- Fixed some of the problems with HTTP 400 BadRequest with "Web import" function


# Version 1.1.14

インタフェースの変更

- なろう検索で観られる小説の詳細ページのレイアウトを変更(画面の小さいデバイスで表示が崩れるため)

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回は軽微な修正となります。具体的には iPhone 5s で表示が崩れているという不都合報告を受けたことで発覚した問題への対応となります。つまり、ユーザの皆様からの不都合報告には本当に助かっています。これからもよろしくお願い致します。

それでは、これからも ことせかい をよろしくお願い致します。

# Version 1.1.14

Interface change

- Novel information page layout changed (for small display device).


# Version 1.1.15

インタフェースの変更

- Web取込機能を使って取り込んだ小説について、個々の章を表示している画面に再ダウンロード用のボタン(回転している矢印)を追加

問題の修正

- バックアップファイルで小説等を読み込み直す時に、画面が凍りついたり ことせかい が落ちやすくなっていた問題を(一部)修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正も細かい改良やバグ修正が主となっております。今回のバグ修正などもユーザ様からのご指摘があって気づいた問題になります。いつもありがとうございます。最近は問題のご指摘だけでなく、かなりしっかりとした状況の再現方法まで伝えて頂けていて、手元での問題の再現が楽になることで問題の修正がやりやすく、とても助かっています。ありがとうございます。

以上手短になりますが、今後共 ことせかい をよろしくお願い致します。

# Version 1.1.15

interface change

- Added a button for re-downloading (rotating arrow) to the screen displaying individual chapters for the novel captured using the "Web import" function.

bug fix

- Corrected (some) the problem that the screen froze or NovelSpeaker fell easily when reloading the novel etc in the backup file.


# Version 1.1.16

問題の修正

- 「ルビはルビのまま読む」がONになっていても最初の1章分は効いていなかった問題を修正
- "*" が連続している部分を読み上げようとすると落ちるので、無害な文字へと読み替える読み替え辞書として追加するように

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

前々からお問い合せのありました、ルビはルビのまま読むが効いていない、という問題の一つが手元の端末で再現するのを確認致しましたので、修正しました。ご迷惑をおかけてしまって申し訳ありませんでした。
ここ最近はバグ修正のアップデートばかりになっているんですが、これらのバグ修正は全部ユーザ様からの不都合報告から発覚しているように思います。単に私のテストがしょぼすぎる(マトモなunit testが書かれていないとか)のが原因の一つではあるのですが、ユーザ様達からの不都合報告には本当に助かっています。ありがとうございます。

それでは、今後共 ことせかい をよろしくお願い致します。


# Version 1.1.16

bug fix

- fixed: Even if "Speech ruby only" is ON, the first chapter was not working
- Since it falls when trying to read a part where "*" is consecutive, it is added as a replacement dictionary to read as harmless characters


# Version 1.1.17

問題の修正

- 文字入力が必要な部分で、Enterを押さないと保存されなかった問題を画面外タップ等でキーボードを消しても反映されるように修正
- Bluetooth機器が外れた時に再生が停止しなかった問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

サポート周りを充実させたことで、不都合報告などでとても助かっているのですが、逆にお問い合わせの件数が増えてしまってちょっと大変になっています。どうすればいいんでしょうかね……(´・ω・`)

あ、問い合わせをしないで欲しいと言いいたいわけではなくて、逆にお問い合わせがあるのはありがたいというか問題もみつかりますしたまに褒めてもらったりして元気も貰えますし利点が多いんですけれど、単純に数が多いと一人で対応するのには限界があるなぁという感じです。かといって、定型文などのそっけない返事とかを返せばいいのかというとそれだと問い合わせ窓口を設けている意味がなくなっちゃいますし、問い合わせ窓口を減らせば昨年末あたりからの怒涛の不都合修正リリースみたいなこともできなくなりますし、といっても問い合わせの量が増えるとそればっかりに時間が使われてしまって……うーん……(´・ω・`)
せっかくお問い合わせの話題を書いたのでついでになりますが、不都合報告をされる時は、「〜が動きません」みたいな簡潔な表現ですと、開発者側の手元で再現できない事が多いので、不都合報告をされる場合は「ことせかい を一回も使ったことが無い人でも同じ操作ができて、問題を認識できるくらいの情報」をつけてくださいますようお願いします。情報が少ないと開発者側の手元で再現できず、再現できない問題は直そうにも直せませんので対応できないことになり、「そちらでは動かないんですね……こちらの手元では動いてるんですけどね……(´・ω・`)」という気持ちだけが残る後味の悪いお問い合わせになってしまいます。お返事ができる場合には「もうちょっと具体的にどのWebサイトのどの小説の何ページ目のどんな文章の辺りでそれが起こるかを教えて頂けますか？」といったような形で開発者側の手元でも再現できそうな情報を引き出すためのお返事を出しているのですが、お返事が必要ないと書かれているとそれもできずに残念な気持ちだけが残る感じになってしまっています。といっても、お返事を書くのはそれはそれで大変なのですけれども……本当にどうしたものか……(´・ω・`)
ついでついでに、お問い合わせで「〜は〜ですか？」と疑問形で終わっているのに返信は必要ないとなっていたりすると、「はい、〜は〜ですね」と思いながら返信できないというなんともモニョモニョする感じになっておりますので疑問形で投稿される場合は返信を許可にして頂く事を考慮してみてくださいね(´・ω・`)

うーん、こんな泣き言を書いて何がしてもらいたいかというのは特に何をしてもらおうという気もないのですけれど、現状ではそのような事になっておりまして、何か新しい機能の実装をお待ち頂いている方々にはとても残念なのですけれどあんまり新しい機能向けの開発の時間が取れていませんというお知らせになっていたり、簡潔で内容の薄い不都合報告を送って頂いている方にはわざわざ不都合報告を書く時間を取って頂いたにもかかわらず(開発者の手元で再現できないという理由で)対応もできずに申し訳ないという気持ちを伝えたいというか、お問い合わせの枕などでお褒めの言葉を添えてくれている方にはとても元気をもらっていていつも本当にありがとうございますと厚く御礼申し上げたいというか……うーん……(´・ω・`)

と、いうわけで、特に何の結論もないただの泣き言のリリースノートになってしまいましたけれども、これからも ことせかい をよろしくお願いいたします。



# Version 1.1.17

bug fix

- Corrected so that even if you erase the keyboard by tapping off the screen etc., the problem which was not saved unless you press Enter is reflected in the part where character input is necessary
- Fixed an issue where playback did not stop when Bluetooth device was disconnected


# Version 1.1.18

問題の修正

- 読み上げ時に別のタブに切り替えたりするなどをすると読み上げ位置がズレたりと色々問題が多かったため、読み上げ中に別タブに移動するなどした場合には読み上げを停止するように
- 最後まで読み上げた後の終了時のアナウンスが発声されない場合があった問題を修正
- 小説の本文を表示している状態から本棚等に戻った時に、読み上げている小説の情報が壊れる可能性があった問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回も問題の修正のみのリリースとなります。問題への対応のため一部仕様が変更されています。今までは読み上げをさせながら別の小説を探すなどの操作ができていたのですが、状態管理周りが大変になってしまっていたのでこれをやめました(小説の本文が表示されている状態から抜けようとすると読み上げが停止するようになります)。
また、恐らくはかなり前から潜んでいた問題を修正しました(開いている小説を別の小説に切り替えた後に読み上げを開始すると変な動作になる等の現象として観測できていたと思われます)。この問題が発生した後は色々な動作が不安定になっていたと思われます(分かる人にはわかるように書くと delegate が開放されたはずの object を呼び出していました)。

ということで、特に何の新機能もないリリースばかりになっておりますが、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.18

bug fix.

- Speech stopped when moving to another tab during speech reading. This was the cause of causing various problems.
- Fixed an issue where announcement at the end after speaking to the end might not be uttered
- When returning to the bookshelf etc from the state displaying the novel text, we fix the problem that there was a possibility that the information of the novel being read might be broken.


# Version 1.1.19

問題の修正

- 小説を開いた時(又は別の章に移動した時)に表示位置が変化しなかった問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回も問題の修正のみのリリースとなります。

立て続けの問題修正のみのリリースで書くことがなくなってきました！(ﾟ∀ﾟ)b
ということで、余談というかご提案を頂いたものへの返信などをしてみようかと思います。

読み上げ時にコントロールセンター(画面の下から引き出すと出て来たり、ロック画面に出てくるアレです)に表示される情報で時間が出るといいなぁというご意見を頂いたのですけれど、ざっと実装の実験をしてみた限りでは色々と面倒くさい問題を解かないと駄目そうなのでお蔵入りにすることにしました。簡単に説明致しますと、「読み上げる時間が推測しにくいが登録するのは時間」という事と、「再生位置の更新をアプリ側から伝えられない(勝手に更新される)ので『今はだいたいこの辺り』という情報を反映できない」ためです。まぁ、だいたいこの文章量なら3分位なんじゃない？って当てずっぽうで3分と宣言しておいて、2分半で読み終わっちゃったり、3分過ぎても読み終わってなかったりしてもいいのならそれはそれでいいのですが、多分、コントロールセンターで表示されている情報と一致しないとかいう不都合報告が飛んでくるんじゃないかと思いますのでそういうツッコミどころを増やすようなものになるのであれば実装はできないなぁという判断になりました。何かこういうことをしたらいいんじゃない？といったご提案があれば教えていただければと思います。

それでは、これからも ことせかい をよろしくお願いいたします。



# Version 1.1.19

bug fix

- Fixed an issue where the display position did not change when opening a novel (or moving to another chapter)


# Version 1.1.20

インタフェースの変更

- 設定タブにある「開発者へ問い合わせる」機能に新機能等の提案用のフォームを追加
- 小説の本文を表示している時、上部に追加された地球のアイコンからその小説のWebPageをSafariで開けるように

問題の修正

- 自作小説の編集中に登録を押さずに戻っても、内容が保存されるように

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回もお問い合わせについての回答をしていきます。
なお、ここに回答が書かれるということは、実装しないと決めた事などのものが多くなります(実装するのであれば実装して上部の更新情報に乗せることになります)ので、基本的にはユーザ様方には寂しい話となります。

まず一つ目は、読み替え辞書をクラウド的なものでユーザ間で共有して編集できないかというご提案です。
これは実現したらとても良いものになるとは思うのですが、そのクラウド的な物を維持するのにはお金がかかるので、ことせかい の開発者側としては対応できない案件となります。ことせかい が何らかの形で定常的にお金を生むような形にしていればよかったのかもしれませんがそうはなっていませんし、今から何らかのお金を生む要素を入れるのは多くの人が望まない事ですよね。なので、やる気はありません。ただ、数年間分のサーバ費用にオマケもつけるからやってくれという人が現れたり、自分がサーバ側を管理運営するのでアプリ側はなんとかしてくれという人が現れたり、この無料のサービスをこうやって使うと実現できるんじゃね？というウルトラCを考えついたりしたらあるいは、という気もしなくもありません。(もちろん、その費用が尽きたりサーバ運営をしてくれている人が諦めたりその無料サービスから想定外の使い方しちゃ駄目と怒られたらそこでそのクラウド読み替え辞書共有サービスは終了になりますので、不安定なサービスであるといえます)

二つ目は何らかの問題で期待しないデータがダウンロードされてしまった場合の話です。
これは、例えば小説ではなく、「アクセス数が多いのでエラー」といったものがダウンロードされてしまった、というような場合の事です。
現状では、既にダウンロードして登録されてしまった部分(章)を再ダウンロードする方法はありません。
内部的には HTTP のステータスコードでエラーを返してくれている(200 OK ではない場合、例えば 429 Too many requests を返している)場合であれば、ダウンロードが失敗したとみなして保存せずにダウンロードを終了しています(していない例がありましたら不都合になりますのでお問い合わせフォーム等から教えてください)。逆に、HTTPのステータスコードによるエラー以外で「アクセス数が多いのでエラー」という文字列が取得できてしまう場合(200 OK で取得したデータの場合)には、ダウンロードが失敗したかどうかを判定するのは難しいため、そのままの文字列が保存されてしまいます。これをユーザ様の側で「この章だけ再ダウンロードせよ」という指示を出せるようにしたらよいか、とも思ったのですが、現在の内部データベース仕様ですと「その章」がどんなURLであったのかの情報が不足しており、再ダウンロードすることができないために実現できませんでした(現状では最初にダウンロードしようとした章のURLと、最後にダウンロードしようとした章のURLしか保存されていませんので、10章分読み込んでいた場合には2章から9章までは再ダウンロードすることができない、という状態です)。
なので、「アクセス数が多いのでエラー」といったようなエラーメッセージそのものが保存されてしまっている場合は一旦小説を本棚から削除して、通信環境の良い所で再度ダウンロードしていただく必要があります。
この問題については将来的には対応しようとは思っているのですが、現在の内部データベース形式では上記の理由で無理となります。また、将来的に対応できたとしても、現在既にダウンロード済みのものについて(上記の例だと2章から9章について)はURLを推測できない関係上、対応が不可能な問題となります。予めご了承ください。

三つ目は縦書き表示について。
まず、ことせかい は「読み上げ」アプリですので「目で読む」ための機能については真面目にサポートするつもりはありません。
また、縦書き表示についてのお問い合わせは何度か受けておりますので少し調査してみたことがあるのですが、残念なことに簡単には縦書き表示はできそうにありませんでした。
グダグタと調査したものを書き下しますと、NSAttributedString に NSVerticalGlyphFormAttributeName 辺りを設定すると縦書き表示ができそうなのですが、1行分しか縦書き表示してくれないようであったり、TTTAttributedLabel というライブラリを公開してくれている人が居てそれを使うと良さそうだと思ったら、Label であって TextView ではないのでスクロールできなかったり、UIWebView に CSS で writing-mode: vertical-rl; 辺りを含ませた物を表示させれば綺麗な縦書き表示ができるかと思ったけれど、現在の読み上げ位置をハイライトする方法が一筋縄ではいかなくて断念したり、といった感じです。最後の UIWebView 辺りの仕組みがうまく動くのであれば表示している WebPage をそのまま読み上げさせる事や、挿絵を表示しながらの閲覧もできるようになりそうでいいかなぁとも思ったんですけれども、読み上げアプリとしては読み上げ位置が見えないのはなぁということでお蔵入りになりました。なお、これらは 2,3年前 に調査したものになりますので、今ではもっと良い方法があるかもしれません(その辺りの知識のある方がおられましたら教えていただければ嬉しいです)。

蛇足的にもう一つ。ことせかい の中の色んな所にあるスライダー(左右にスライドして値を入力する奴)なんですけれど、これ、微妙な値を指示したい場合にはちょっと面倒ですよね。そんな時は、スライダーのつまむ所(丸い奴)をタップしたまま(つまむ所が見える状態になるまで)指を下にずらして、そこで指を左右に傾けるような形で位置を調整すると微妙な値もなんとなく入力できます。まぁ正確に0.1づつ動かしたい、みたいなのには使えないのですけれど、覚えておくとちょっと便利な感じです。あ、これは左右への0.1づつとかのボタンを配置するのが面倒だから言っているのではなくてですね、ボタンを配置てしまうとiPhone SEとかの幅の狭い端末だとレイアウトが崩れちゃってちゃんと操作できなくなっちゃうのでボタンを配置できない所があったりするのです。

以上となります。
それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.20

Interface change

- Add a form for suggesting new functions etc. to "query to developers" function on setting tab
- When displaying the text of the novel so that the novel's WebPage can be opened in Safari from the icon of the earth added to the top

Bug fix

- Even if you go back without pressing registration while editing your own novel, so that the contents are saved


# Version 1.1.21

インタフェースの変更

- 設定タブに「本棚に栞の位置を表示する」のON/OFFの設定を追加

問題の修正

- Web取込機能にて取込を行った小説を開いた時に、読み込まれた章の数がうまく表示できていなかった問題を修正
- ダウンロード中に本棚から小説を削除した時に、ダウンロードが継続することで壊れた小説ができてしまう問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助かっています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回のアップデートでは、読んでいる位置をプログレスバーで表示してほしいという要望に対応してみたのですが、どうにも本棚ページの雑然としている感じが強くなってしまったようにみえましたので、標準ではOFFにしておいて、設定タブの所からON/OFFを切り替えて利用して頂く形にしました。
その他の問題の修正に関しましては、これもユーザ様からのお問い合わせからの修正になっています。いつもありがとうございます。

また、前回までにリリースノートで告知しておりましたQ&A的なものを、サポートサイトの1ページとして纏めておきました。ご利用ください。

それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.21

Interface change

- Add "Display bookmark position on Bookshelf" toggle switch on Settings tab.

Bug fix

- Fixed an issue where the number of chapters loaded could not be displayed well when opening a novel that was imported by the web import function
- Fixed a problem that broken novels will be created when downloading continues when downloading novels from bookshelf during downloading

# Version 1.1.22

インタフェースの変更

- 小説の本文を長押しした時に出るメニューを「読み替え辞書へ登録」のみにするかどうかの指定を設定タブに追加
- 小説の本文を表示する字体を選択するボタンを設定タブの「表示文字サイズの設定」上部に追加

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

ゴールデンウィークは何をやろうかなぁと思いながら、結局 ことせかい の改良をしている私です。今回も不採用となりましたお問い合わせについて回答していきます。

ルビを文字の上に表示して欲しいというお問い合わせについて。
まず、ことせかい は「読み上げ」アプリですので「目で読む」ための機能については真面目にサポートするつもりはありません。
なのですが、簡単に実現できるのに実装しないのだとすると悪い気もしますので、調査してみました。しかし、残念なことにルビの表示を簡単に実現するのは難しいという結論に達しましたため、この機能については見送りました。
とはいえ、調査している所で小説の本文を表示している部分の字体を変えるのはそれほど大変でもなさそうでしたので、字体を変える機能を実装しました。選べる字体は多いのに日本語の文字の字体が変わるものは少なそうなのが気になりますが、選択できないよりはいいのかなぁと思っています。

それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.22

Interface change

- Add to the setting tab whether to set only the menu to be displayed when long-pressed the novel's body "Add correction of the reading"
- Add a button to select the font that displays the novel's body to the upper part of "Setting the display character size" on the setting tab


# Version 1.1.23

インタフェースの変更

- 本棚での栞の位置表示ゲージについて、読み終わっている場合にはゲージの色が変わるように
- 読み上げ中のスクロール位置を読み上げている場所より少し先までスクロールするように変更

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

立て続けにリリースしてきた細かい修正も、そろそろ一段落したのではないかと思っているのですが、ゴールデンウィークで今まで使っていなかった人が使いだしたのか何なのか、今までは言われていなかったような視点からのお問い合わせが多く寄せられていて、なるほどそんな問題があったのか、そこで詰まってしまうのか、といったような気付きを得ています。ありがとうございます。
それで、最近はこのような細かい修正ばかりをしていて前から作っている本棚周りの改修が全然進んでおりませんので、そろそろ本当に一段落をつけないとなぁと思っている所です。とはいえ、本棚周りの改修時に CoreData のカスタムマイグレーションで躓いておりまして、そのあたりの知識のある方に色々と教えていただきたいなぁと思っていたりする位、遅々として進んでおりません。本棚周りはかなり前からアナウンスしておりますし、早めにリリースできるところまで持っていきたいです……(´・ω・`)

というところで、近況でした。
それでは、これからも ことせかい をよろしくお願いいたします。



# Version 1.1.23

Interface change

- About the position indicator gauge of the bookmarker on the bookshelf so that the color of the gauge changes when reading is finished
- Change the scroll position being read so that it scrolls slightly beyond the place to read aloud


# Version 1.1.24

インタフェースの変更

- コントロールセンターでの前の章や次の章へのボタンを少し巻き戻し、少し進めるボタンへ変更する設定を設定タブに追加
- イヤホンのリモコンからの巻き戻し・早送りコマンドに対応

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正は使い方がいまいちよくわからないところもありそうなので解説しておきます。
ことせかい はバックグラウンド再生中にコントロールセンター(ロック画面のアレとか画面の下から指を滑らせて出て来るアレです)で「次の章」や「前の章」への移動が可能でした。このコントロールセンターでの「次の章」や「前の章」のボタンをその章の中の「少し後」や「少し前」へのボタンに変更するための設定を設定をタブに追加しました。ただ、変更されたボタンは15秒巻き戻しや15秒先送りのような見た目をしており、「正確に15秒巻き戻ってないぞ」といった疑問が生じるかもしれませんが、そういう細かいことは言わずに使っていただければと思います。
また、イヤホンのリモコンにての巻き戻しと早送りにも対応致しました。こちらは既に使いこなしている方には問題ないかと思われますが、全く使ったことの無い方(私はそうでした)もおられるかと思いますので使い方を書いておきます。
iPhoneなどを買った時についてくる純正イヤホンにはリモコンがついているのですが、そのリモコンのボタンの真ん中をカチカチカチッと連続して押すと、「次のトラック」「前のトラック」「早送り」「巻き戻し」ができるのです。それぞれ、

再生・停止：真ん中ボタンを一回押す
次のトラック： 真ん中ボタンを二回素早く押す
前のトラック： 真ん中ボタンを三回素早く押す
早送り：真ん中ボタンを二回素早く押し、二回目は押しっぱなし
巻き戻し：真ん中ボタンを三回素早く押し、三回目は押しっぱなし

と、それぞれの機能を呼び出す事ができます。
それで、今回のアップデートではその早送りや巻き戻しに対応した、という事になります。

そういえば最近のiPhoneにはイヤホンジャックは無いのでしたっけ……？ その場合は Bluetooth イヤホンでやるのだと思うのですけれど Bluetoothイヤホン での早送りや巻き戻しはどうやるんでしょうか。手元の Bluetooth イヤホンはボタンが一つという残念なモデルでして、ボタンを三回押して押しっぱなしにしたところ言語設定が中国語？になってしまって大混乱しました。(´・ω・`)

とりあえず Bluetooth イヤホン での動作確認はできていないのですが、純正イヤホンでの動作確認はだいたいできていると思います。何か不都合などありましたら教えていただければ嬉しいです。

それでは、これからも ことせかい をよろしくお願いいたします。



# Version 1.1.24

Interface change

- Added settings to change to previous button in control center, button to next chapter a little bit, change to a little advance button
- Corresponds to rewind / fast forward command from earphone


# Version 1.1.25

インタフェースの変更

- コントロールセンターに再生時間を表示するか否かの設定を設定タブに追加
- 小説の本文の表示時に画面を黒系の背景にするか否かの設定を設定タブに追加

問題の修正

- Bluetoothイヤホンのボタン操作で再生が停止しなかった問題を修正


追伸

評価やレビュー、ありがとうございます。特にサポートサイト側からのご意見ご要望フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

Bluetoothイヤホン からの停止が効かなくなった件は申し訳ありませんでした。やはりちゃんと使っていないデバイスのサポートは難ありですね……(´・ω・`)
あと、前のリリースノートでも書いたのですが、開発者の手元にありますBluetoothイヤホンでは次のトラックへの移動や早送りといった機能を使えないようなので、それらの実験ができずに動くのか動かないのか、動いたとしてちゃんと動いているのかといった確認ができていません。動いていないのであればなんとかしたいのですが、何を買ったら安く、かつ早めに調達できるでしょうか。iOSで次のトラックや早送りなどの操作ができるBluetooth機器の型番や操作方法などがわかる方がおられましたら教えていただければ嬉しいです。

また、今回のリリースでは、コントロールセンターに再生時間を表示させる機能をつけました。これはちょっと前のリリースノートで実装しないと書いた機能そのものになります。なぜ今回実装しましたかといいますと、前回調査した時は再生時間の所に出てくるツマミを操作して目的の再生位置から再生をさせる方法がわからなかったのです。そうすると単に再生時間しかわからない状態でしたので、正確な値が表示できないし、あんまり有用にはならないのにツッコミどころが増えるなぁと思って実装を見送ったのでした。しかし、今回別件で調査していた時に、再生時間の所に出てくるツマミを操作した時の作り方がわかりましたので、実験してみましたところ、これはツッコミどころがあっても十分有用だろうという感触でしたので、実装しました次第です。

他に、暗めの場所で読む時に白背景が明るくて辛いというお問い合わせがありましたので、黒背景に変更できるような機能もつけてみました。ただ、前から何度も申し上げておりますように、開発者としましては ことせかい での「目で読むための機能」は真面目にサポートする気はありません。なのですが、そんなに時間のかからないような形式で実装できそうでしたので、実装致しました。そのため全ての画面が黒背景になるであるとか、ナイトシフトモードと連動して夜中は黒背景になるであるとかいったようなイケてる機能にはなっておりません。設定タブでON/OFFを切り替えてご利用ください。

ところで、ここ最近の設定タブへの設定の追加が沢山になっていて、設定タブの中身がごちゃごちゃしてきました。ここ最近に追加された ON/OFF 機能の説明文が長いのが特に気になっています。こういうUIを綺麗に設計できる人が羨ましいです。どうしたもんですかね…… 何か良いお知恵がありましたら教えていただければ嬉しいです。

以上となります。
それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.25

Interface change

- Added setting tab on whether to display playing time in control center to setting tab
- Add setting to the setting tab whether to make the screen black-based background when displaying the novel text

Bug fix

- Fixed an issue where playback did not stop due to button operation of Bluetooth earphone


# Version 1.1.26

インタフェースの変更

- 本棚で「下に引っ張って更新」ができるように(iOS10以上のみ)
- ページめくり時に音を鳴らすのON/OFF設定を設定タブに追加
- URIを読み上げないようにする設定を設定タブに追加

問題の修正

- 小説の本文を表示した状態でタブを何度か切り替えると、前後の章へのスキップが1章分ではなく複数章分スキップしてしまっていた問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

結局今回のゴールデンウィークは ことせかい の更新作業しかしていなかったのでそろそろ燃え尽きそうな気がしないこともない開発者です。こんにちは。
今回もユーザの皆様からのお問い合わせから、簡単に実装できそうなものと問題の修正をお届けします。

本棚で「下に引っ張って更新」ができるようになりました。これは iOS 10 からは楽に実装できるようになっているのに気づいておりませんで、別件で調査中に気づきましたのでそのまま実装致しました。

ページめくり時に「ぱらり」といった感じのページをめくった感じの音を鳴らせるようにしました。ただ、うるさいと感じる方もおられるかもしれませんので、利用したい方は設定タブでONにしてご利用ください。

https://example.com/.../ といった文字列を読み上げないようにする設定項目を設定タブに追加しました。これで「えいちてぃてぃぴぃえすころんすらっしゅすらっしゅ……」というまぁわかるのだけれど使えないので読み上げないでいいよという気分から解放されるかと思います。なお、この機能は読み替え辞書が正規表現マッチに対応する場合には削除される可能性があります。ご留意ください。(今のところ正規表現マッチができるようにする予定は無いのですが、一応、です)

先日コントロールセンターやリモコン周りの修正を入れた時に、今まで使っていた iOS 10 で非推奨になった仕組みから別の新しい仕組みに変更しております。これによりいくつかの新機能が実装できましたが、同時に今までできていた事でできなくなった事がありました。できなくなってしまったのは単に実装漏れですので直しています。なお、今回の修正でコントロールセンターやイヤホンのリモコン周りの問題はあらかた片付いたのかなと思っているのですが、何分開発者はあまりイヤホンのリモコンを使っておりませんので、問題に気づいていない可能性が高いです。直されていない問題があるのに気づかれている方がおられましたらサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告からこっそり教えていただければ幸いです。

蛇足になりますが、ことせかい にお金を生む仕組みが何も無い事を心配されるお声を受け取りました。良い機会ですので方針の告知と施策の実行をしておきます。
まず、ことせかい のアプリ内でお金を生むような仕組みを実装する事は考えておりません。これは単に、今までがそうだったから、です。もう少し深く言うと、「人間は与えられるモノには鈍感だが失うモノには敏感である」というのを信じているから、になります。ことせかい にアプリ内課金やアプリ内広告を実装した場合、ゲンナリするようなレビューやご意見ご要望が増えるでしょう。そんな事は全く望んでいませんし現状で既に耐えるのが大変なのにこれ以上増えたら多分耐えられなくなってアプリを消して撤退するのではないかと思います。
次に、ことせかい は趣味で開発しているものになりますので、金銭的な何かを受け取ったとしてもそれを理由に開発や運営への強制力を行使して欲しくはありません。
以上の事から、大まかな方針としましては、金銭を生むような仕組みを導入するのには及び腰となっています。
ただ、評価していただくのは嬉しいですし、単純に見返りなしで現状のもの(問題も含む)を利用した対価という形で金銭をいただけるのであればそれはもちろん嬉しいですので、お試しで Amazon の欲しいものリスト を作って公開してみます。サポートサイトにリンクをつけておきますので上記の内容を理解した上でそれでも何かを与えても良いと考える方はご利用ください。

それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.26

Interface change

- Enable Pull-to-refresh on bookshelf (iOS 10+ only)
- Add ON / OFF setting to sound when turning pages to the setting tab
- Add settings to prevent setting up URIs to the setting tab

Bug fix

- Fixed an issue where skipping to the previous and next chapters skipped multiple chapters instead of one chapter when switching the tab several times with the novel text displayed


# Version 1.1.27

インタフェースの変更

- なろう検索 経由で取得した小説の詳細画面に連載状態(完結や連載中等の状態)を追加

問題の修正

- 「新規自作小説の追加」で追加した小説にページを追加すると最初のページが消える問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

そろそろ本棚周りをなんとかしたいのですが、その時間を作れていません。このところの立て続けのリリースや、ユーザサポートを行うために使っている時間が多いためです。

なお、本棚周りの改修は例えば

- お気に入りを設定して検索しやすく
- 「最後に読んだ」順にできるように
- タグをつけて分類できるように

といったような、本棚で本を探すのが大変なので例えばこうしたら良いのではないか、というご意見ご要望に対応するものです。また、本棚周りの改修はまだ形になっておりませんので何ができるようになるといったアナウンスができる状態ではありません。

また、不都合の報告をして頂いている方に申し上げておきます。
寄せられる不都合報告の多くは、最初のご報告では情報不足で再現しません。また、不都合報告をされる方向けに「返信を書くだけでも大変なので返信は不要にして欲しい」というような事を書いているからなのか、返信用のメールアドレスが無かったり、返信を許可にされずに不都合報告をされる方が多くおられます。開発者の手元で再現できない不都合報告で、返信が許可されていない場合は開発者側としては打つ手がなく、対応できません。そうすると、せっかく不都合報告をしていただいたけれども何も改善しなかったということになり、不都合報告をして下さった方も本意ではないと思います。
返信が許可されているならば、開発者から詳しい状況をヒアリングするような返信を差し上げることができます。
ですので不都合報告をされる方はまずは返信を許可にするか、メールアドレスを書いてください。その後、「再現ができない場合のみ返信を希望します」というような言伝を報告の内容に書いていただければ幸いです。

また、アプリが終了するような問題の不都合報告の場合、アプリ内の設定タブの下部にあります、「開発者に問い合わせる」からの不都合報告フォームを利用して、不都合の起きた日時を正確に入力した後、不都合報告メールを作成する時に操作ログを添付する事を考慮してください。操作ログ上のアプリが終了した時間近辺を確認することで開発者の側で非常に似通った状況を作り出すことができ、より再現性が高まります。
アプリが終了するような問題の場合は特に、様々な要因が関わる可能性があり、その全てをユーザ様方で不都合報告の文章記述欄に書かれるのは恐らく難しいと思います。それを補完するのがアプリの操作ログとなります。

例えば、「xxxxという文を読み上げさせると落ちます」という内容で不都合報告を受けたことがあります。
開発者側ではその「xxxx」が書かれた自作小説を作り、読み上げさせ、落ちない事を確認しました。
そこで、「〜という実験を行ったが再現はしなかった。アプリが毎回落ちるような状況であれば、その小説とその読み上げている場所を教えてほしい」という返信をし、「この小説のここの部分で落ちる」という返信を受け取りました。
そこまでの情報を得ることで、実際には「******」を読み上げていた時に終了する問題であることが確認できました。
(実際のところ、「*******」という "*" が連続して現れる部分を読み上げさせるとアプリが落ちるという問題があります。現状では "*" を" " に読み変えるような設定を読み替え辞書に強制的に登録することでこの問題を回避しています)

この例では、アプリが落ちる事を確認したユーザ様は、特定の部分を読み上げさせるとアプリが落ちる事を確認するまで実験をし、その結果として「xxxx」を読み上げさせるとアプリが落ちると報告してくださったのですが、問題は本当はそこではなく、別の部分(「******」)にあったのを気づけなかったという事になります。

開発者としましては、不都合の報告を書くという手間の上にわざわざ問題の原因を特定するような作業をしていただいたのに、それが原因で情報が少なくなってしまって再現できずに対応もできないという状態になってしまうのはとても心苦しく、残念です。幸い、この例の場合は返信ができましたので詳しい状況のヒアリングができましたが、それが許可されていない多くのご報告は特に何もできず、悲しい気持ちだけが残り続けています。

さて、この例の問題については、アプリ内の不都合報告フォームから、操作ログとアプリの終了した日時を送信していただくことで、「どの小説のどの部分を読み上げている時に不都合が起きたのか」が伝わりますので、最初からそのようにしておいていただければ、返信できなかったとしても問題なく不都合の原因を特定できたのではないかと思っています。

ですので、不都合報告をされる方は出来る限りの情報を出すという意味で、アプリ内の不都合報告フォームより、アプリの操作ログの添付と不都合の起きた日時を正確に入力して頂きたいと思います。
もちろん、アプリの操作ログだけで全ての問題が解決するわけではありませんので、返信を許可していただく事も同様に考慮していただければと思います。
よろしくお願いいたします。

以上となります。
それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.27

Interface change

- Added serial status (completion, serialization etc.) on the details screen.

Bug fix

- Fixed a problem that the first page disappears when adding a page to the novel added in "Add new self-made novel"


# Version 1.1.28

インタフェースの変更

- アプリ内からの問い合わせフォームにて、「この問い合わせに返事が欲しい」の初期値を「はい」に変更

問題の修正

- Web取込等で小説を新しく取り込んだ時に、空の「新規ユーザ小説」が作成されてしまう問題を解消
- "*" が連続している部分を読み上げると落ちる問題について、以前は "*" に関する読み替え辞書が登録されている場合は書き換えを行わなかったが、それでも落ちる人が居るようなので強制的に "*" は " " に読み替えるように起動時に上書きするように変更


追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

ここ最近、特にゴールデンウィーク中はとても多くのご意見ご要望、特に新機能の提案を受けました。開発ジャンキーな開発者としましては使って頂けた上に新しい機能まで考えてくださって新しい機能について考える事なく機能開発に勤しむことができ、さらに実装すると喜びの声という形のフィードバックがいただけたりすることで、いつも楽しく開発させて頂いています。ありがとうございます。

ただ、既にリリースノートやQ&Aにて回答されているものにつてのお問い合わせが混じっている事も多くなっております。なので、お目障りとは思うのですが、アプリ内やサポートサイトからのお問い合わせフォームにゴテゴテと「問い合わせをする前にこれを読め」と言わんばかりの項目を追加しています。お問い合わせを行う皆様にはお手数をおかけしますが、ご協力の程よろしくお願いいたします。

同様に、お問い合わせに返信が必要ないとされているお問い合わせが多くあり、それらについて返信ができればなぁと思う事も多いです。そのようなお問い合わせに返信できないのは悶々とした何かが溜まっていってしまって精神衛生上あんまりよくなさそうです。なので、今回のアップデートではアプリ内からのお問い合わせでの「このお問い合わせに返信が欲しい」の項目の初期値を試しに「はい」にしてみます。
ただ、ここ最近のお問い合わせは数が多すぎてしまっていてそろそろ自分ひとりでなんとかできる数を超えそうに思っています。ですので、あっという間にパンクしてしまって「返事が欲しい」の初期値を「いいえ」に戻すだけのリリースをするかもしれません。

それでは、これからも ことせかい をよろしくお願いいたします。



# Version 1.1.28

Interface change

- In the inquiry form from within the application, change the initial value of "I want a reply to this inquiry" to "Yes"

Bug fix

- Eliminate the problem that an empty "new user novel" will be created when newly importing a novel by web retrieval etc.
- In the case where a replacement dictionary relating to "*" has been registered in the past, concerning the problem of falling off when reading out consecutive parts of "*", we did not rewrite, but since there seems to be a person who is still falling, "*" is forcibly replaced with " " Changed to overwrite on startup


# Version 1.1.29

問題の修正

- 日付と時刻の設定で24時間表示をOFFにしている場合、なろう検索での検索結果に出てきた小説の更新日時が "-" になってしまう問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正は上記の問題一つだけです。この問題は

1. 24時間表示を OFF にしていて

2. 小説家になろうから小説の詳細情報を取得した時

の2つの条件が重なった時に起こります。
また、なろう検索 経由でダウンロードされた小説の詳細情報は更新を行った時に書き換えられておりますので、
24時間表示を OFF にしている時に本棚で更新すると、なろう検索 経由で取得した小説の全ての更新日時が "-" になり、
逆に24時間表示を ON にしている時に本棚の更新を行うと、更新日時が正常な値になると思われます。
そのため、上記のアップデートがかかった後になっても更新日時が "-" になっている小説が残っている可能性があります。
その場合は再度本棚の更新を行う事で小説の更新日時情報を更新していただければと思います。

以上となります。
それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.29

Bug fix

-  Fixed a problem that the update date and time of the novel appearing in "Search tab" search result becomes "-" when 24 hour display is set to OFF in the date and time setting


# Version 1.1.30

インタフェースの変更

- Web取込や自作小説の編集画面において、小説のタイトルをタップした時に全ての文字が選択状態になるように

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

ここの所のアップデートラッシュでちょっと燃え尽きてる感じもしている開発者です。こんにちは。
今回も上記のインタフェースの変更だけの小規模なアップデートになります。また、今回の修正もユーザ様からのご要望にお答えしての修正となります。いつもありがとうございます。

それでは手短となりますが、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.30

Interface change

- On the editing screen of Web capture or self-made novel, when all the characters are selected when tapping the title of the novel


# Version 1.1.31

インタフェースの変更

- ダウンロード中には画面上部のネットワークアクティビティインジケータ(くるくる回る奴)を表示するように

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

本棚周りの修正をしようとして内部データベースの変更を開始して、内部データベースを変更するならアレやコレもできるようになるよなぁと思いながらアレやコレを内部データベース定義に追加しはじめて、やることが多くなってしまってどうしたもんかと思っている開発者です。こんにちは。

今回の修正は読み上げさせながらダウンロード中かどうかを判断できないなぁと思ったのでダウンロード中のインジケータを表示するようにしてみました。
ことせかい はバックグラウンドで動作はするのですが、あくまでも音声アプリとしてのバックグラウンド動作となりますので、小説のダウンロードをしているだけではバックグラウンドでのダウンロードはできません(多分5分位するとOS側から落とされるような気がします)。また、ことせかい からの小説のダウンロードは、対象となるWebサイト側の制限を回避するために、ゆっくりとダウンロードされるようになっていますので、複数の小説をダウンロードキューに入れていると結構な時間がかかります。ということなので、大量の小説をダウンロードさせようとしている状態で、かつ、音声読み上げをさせずに ことせかい 以外のアプリを使うと、多分ダウンロードが途中までしか行われない状態になると思います。なので、大量の小説をダウンロードさせようとしている時には ことせかい を起動したままにしておくと良い、ということになるのですが、小説の本文を表示しているときなど、本棚を表示していない場合にはダウンロード中かどうかを判断できませんでした。この問題を今回の修正では解消しようかなぁという感じです。

でもこれって、本棚に戻りたくないって事なんですよね。というのは、ことせかい では一度本棚に戻ってしまうと、同じ小説を表示させるためには本棚の中からその小説を選ぶ必要があって、現在の ことせかい では本棚での小説の検索性がよろしくなく、同じ小説を開こうとするのに結構な手間がかかるから、なんですよ。つまり、本棚が使いづらいのが原因で本棚に戻りたくないというわけで。嗚呼、はやく本棚が使いやすくならないかなぁ。開発者なんとかしてよ…… (自分だけれども)
と、いうことで、本棚周りの改修をコツコツと続けてやっていきます。本棚周りの改修に関しては首をながーくして待っていただければと思います。

それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.31

Interface change

- While downloading, display the network activity indicator at the top of the screen


# Version 1.1.32

問題の修正

- 次/前の章へ移動すると表示位置が末尾になってしまっていた問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

取り急ぎ、問題修正のみのリリースとなります。

それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.32

Bug fix

- Fixed an issue where display position ended when moving to the next / previous chapter


# Version 1.1.33

インタフェースの変更

- 小説の本文を表示している時の上部にある地球のアイコンからその小説のWebPageを表示する時に、Web取込タブ側で表示するように
- 設定タブに利用許諾を参照するボタンを追加
- 設定タブにプライバシーポリシーを参照するボタンを追加

問題の修正

- コントロールセンターで前の章/後の章へ移動する時に、きちんと移動できていなかった問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正はWeb取込タブが登録された時、一時的にアプリのレーティングが17+になった原因である、Googleのような検索サイトへアプリ内からの操作だけでアクセスできる状態(無制限のWebアクセスと判断される状態)を回避するために、Web取込タブのホームページに登録されていた Google検索 へのリンクを復活させることが楽にできるようにするための修正となります。
今までも、設定タブの「再ダウンロード用データの生成」で作成したバックアップファイルを書き換えてから復元させることや、初期に登録されているWebサイトを手繰ることでGoogle検索ページをなんとかして表示させることでGoogle検索ページをWeb取込タブのホームページに登録することができていましたが、これからは、

1. Safari で Google検索ページを表示する

2. シェアボタンから「ことせかい へ読み込む」を選択して ことせかい 側に Google検索ページ を小説として取り込ませる(Safari からの「ことせかい へ読み込む」機能についてはサポートサイト下部からリンクしております、「Web取込機能について」内の「Safari からの取込」の項目を御覧ください)

3. その取り込まれたGoogle検索ページを本棚から開き、上部にある地球のアイコンを押す

4. Web取込タブでGoogle検索ページが表示されるのでそれをブックマークに追加する

という手順で Google検索ページ や他のWebサイトをブックマークに登録することができるようになります。

でもそれって無制限のWebアクセスに該当しないのだろうかとも思うのですが、そもそもチャイルドロック的な事がなされている iOS端末 では Safari 自体が開けませんので上記の操作ができないため、問題ないのではないかな、と思っています。駄目であればアプリの審査で弾いてくれると思われるのでこれがリリースされたということは大丈夫ということだと認識しています。

また、ことせかい の利用許諾とプライバシーポリシーを明確に文書化し、アプリ内から確認できるようにしました。プライバシーポリシーはユーザサポート時に必要となるため、お問い合わせを行う場合には同意して頂く必要があります。

それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.33

Interface change

- When displaying the WebPage of the novel from the icon of the earth at the top when displaying the text of the novel, as shown on the Web capture tab side
- Added a button to refer the license to the setting tab
- Added button to refer privacy policy to setting tab

Bug fix

- Fixed an issue that could not be properly moved when moving to the previous chapter / later chapter in the control center


# Version 1.1.34

インタフェースの変更

- 読み上げ時の間の設定にて、「<改行>」と書いたもの(英語環境化では"<Enter>")が改行として扱われるように仕様変更

問題の修正

- 「小説を読むときに背景を暗くする」がONのときに、ステータスバーの文字色が黒のままで読めなかったのを修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

しばらく前のページ切替時の不都合の時に沢山の不都合報告を頂いた事で、普段は何も言ってこない人でも、不都合には敏感に反応するのはまぁ当然なんだろうというのはわかるんですが、そのようなお問い合わせは多少なりとも負の感情が入っているのが見え隠れしていて(中には隠そうともしないでそのままぶつけてくる人も居ますが)、そういうのは数が少なければなんとかなるんですが、数が多いとどうしようもないというか、なんで私はこんなに負の感情をぶつけられているんだろう、なんで私はそんな辛い事をわざわざやっているんだろう、みたいな事を考えてしまったりしたのがずっと燻っていて、いつものように「ありがとうございます」って言う気になれない開発者です。こんにちは。
あ、取ってつけたような慰めの言葉はいりません。この問題はアプリを公開している以上(人間が作っている以上不都合を出さないというのは不可能であるという意味で)避けられない問題であり、かつ、人間という生き物は利益には鈍感だが不利益には敏感なので不都合が出た時だけ行動するのはある意味当然であり、先だっての出来事は利用者の数が増えた事や不都合を出したということがきっかけに前述の人間の特性上起こった当たり前の出来事である、ということで、個人で無償のアプリを提供してユーザサポートまでやる事への限界はここいらあたりだろうな、という気になってきたのを皆さんに知っておいて欲しいというだけです。

では今回も、ご提案は頂きましたが採用できませんでしたアイディアについて告知しておきます。

Version 1.1.20 から導入された、小説の本文を表示している時の上部に表示されている地球のアイコンについて、アイコンを押したときにはその小説のその章のWebPageが開いて欲しい、というご要望なのですが、Web取込で取り込んだ小説については個々の章のWebPageへのURLが保存されていないため、実装できないものとなります。

手短ですが以上となります。
それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.34

Interface Change

- Specification change so that the thing written as "<newline>" ("<Enter>" in English environment) is handled as a line feed at the setting between reading-out time

Bug fix

- Fixed the fact that the character color of the status bar was still black and could not be read when the "Darken the background when reading a novel" is ON


# Version 1.1.35

問題の修正

- 「小説を読むときに背景を暗くする」がONのときに、ステータスバーの色が白に変わったまま読めなくなる場合があった問題を修正

追伸

あんまり ことせかい の開発に元気が出せないのでしばらくはメンテナンスリリースのみ、追伸は省力化でお送りします。原因に当たる事象については Version 1.1.34 のリリースノートを御覧ください。

ご提案で採用されなかったアイディアについての告知

一旦 ことせかい にダウンロードした小説の章が、小説サイト側で更新された場合に再度ダウンロードする方法が無い件について。
既に Q&A に記述した https://limura.github.io/NovelSpeaker/QandA.html#DownloadFailed と同じ理由で採用されません。

以上



# Version 1.1.35

Bug fix

- Fixed a problem where the color of the status bar changed to white and it became impossible to read when "Dark background when reading novels" was ON


# Version 1.1.36

問題の修正

- 編集可能な小説を編集中に、最初に開かれている章(現在読んでいる章)から別の章へ移動した時にその変更が保存されない問題を修正 

追伸

あんまり ことせかい の開発に元気が出せないのでしばらくはメンテナンスリリースのみ、追伸は省力化でお送りします。原因に当たる事象については Version 1.1.34 のリリースノートを御覧ください。



# Version 1.1.36

Bug fix

- Fixed an issue that was not saved when editing an editable novel when moving from the first opened chapter (currently reading chapter) to another chapter


# Version 1.1.37

インタフェースの変更

- 「再ダウンロード用データの生成」で保存される設定項目を増加
- 「再ダウンロード用データの生成」で小説の本文を含むバックアップもできるように
- 対応読み込みファイルタイプに RTF(Rich Text Format) を追加
- 設定タブに「ことせかい について」(バージョン番号の確認)を追加
- 設定タブに「繰り返し再生」の項目を追加

追伸

ことせかい に新規機能を追加しなくした所、思ったとおりお問い合わせが減り、しばらく心を養生することができ、なんとなくやる気が戻ってきた開発者です。こんにちは。

今回の「再ダウンロード用データの生成」の改修によって、ほとんど全ての設定項目が保存されるようになります。
ただ、一部の設定項目については以下の理由により保存されません。

- 「小説の自動更新」のON/OFF：これは通知に関するユーザからの許可が必要となるので単純にONにはできないため、保存されません

既存のバックアップデータには小説の本文が含まれておらず、再度ダウンロードしようとすると小説の数によっては相当な時間がかかるため、小説の本文も含んだバックアップを生成することができるようにしました。ただ、小説の本文を含んだバックアップの作成にはiPhone(やiPad)本体のストレージが結構必要になり(具体的には ことせかい の消費しているデータ量の1.3倍位必要になります)、かつ、そのデータを生成して圧縮するためにかなり時間がかかります。さらに、生成されるバックアップデータはかなり大きなファイルとなりますのでメールとしては送信できないかもしれません(メール以外で共有できるような仕組みは別途考えます)。

また、ことせかい のリリース時に不都合が出た場合に不都合報告が大量に寄せられて開発モチベーションが消えてなくなるという問題を解消するために、ことせかい の利用者様の協力をお願いして、βテスト という形で一部の(βテスト)ユーザに先行配信することで、不都合の発見を事前に行える可能性を増やそうという試みを開始してみます。
サポートサイト下部にβテストの募集要項等のページへのリンクを作成しておきましたので、ご確認ください。

βテストについては、不都合が無いように努力はしますが、不都合が残っている可能性があるのでβテストをしているという関係上、不都合が無いとは言えません。不都合の形によっては最悪の場合、全てのデータが壊れてしまう可能性があります。そのため、バックアップを利用することで状態の復帰をしやすくしようという目論見で今回のバックアップは実装されました。ということで今回実装された完全バックアップはできるだけの状態は保存されるように作成しました(その分生成時に時間やストレージ量がかかったり、バックアップファイルが非常に大きくなる可能性があったりという問題が発生していますが……)。

それでは、今後共 ことせかい をよろしくお願いいたします。




# Version 1.1.37

Interface cange

- Increase setting items saved in "Create backup data"
- In "Create backup data" so that you can also make a complete backup including the text of the novel

# Version 1.1.38

不都合の修正

- 繰り返し再生時に、読み上げ位置が先頭に戻らない場合があった問題を修正

不都合でご迷惑をおかけした方々にはすみませんでした。
新規の機能にリリース後すぐに不都合が発覚して意気消沈な開発者です。(´・ω・`)

ということで今回は不都合修正のみのリリースとなります。
なお、前回のリリースからβテスターの方々にお手伝いしていただいて、リリース候補版ができたあとにすぐにリリースするのではなく、βテスターの方々にテストして見つかりやすい問題を発見していただく期間を設けております。
βテストの告知からあまり時間も経っておらず、βテスターの方々の数は今の所とても少ないのでβテストの効果もそこまででもないのはしょうがないのかな、とは思います。
とはいえ、βテスターの方々の数が増えないとβテスト自体の効果も出ませんし、βテストの効果がでないと最悪の場合は大量に届く不都合報告で開発者が音を上げてAppStoreからアプリを削除して撤退、ということも考えられなくもなくもありません。そんなわけですので 今後も ことせかい を使いたいという皆様は、できましたらば ことせかい のβテストへの参加を検討して頂ければと思います。ただまぁ、βテストへの参加は完全に無償奉仕になりますので強くは言えないと考えています。(振り返って開発者もほぼ無償奉仕なんですけどそこの所はどうなんだろうとか考え始めるとどんどんやる気がなくなってくるのであんまり考えないようにしています。どうせガミガミ言ってくる人はこんな所読んでないんでしょうし)

さて、気を取り直して、お寄せいただいたお問い合わせで返信が許可されていなかったけれどご希望には添えなかった、という件についてこの場でお返事しておきます。

読み替え辞書をもう少し賢くしてほしいというお問い合わせについて。
これは多分正規表現で書き換えができるような形にするとよさそうな気がしますが、今の所は内部データベースの内容を変更したくないのでちょっと先送りにしようかと思っています。GitHub側に issue を立てておきましたのでご確認ください。

Web取込機能で取り込めないWebサイトのお問い合わせで、個人サイトをお知らせいただいた方の件について。
お知らせいただいたWebサイトの小説を拝見したのですが、その小説の本文のページの中に次の章へのリンクがありませんでしたので対応ができないWebサイトとなります。また、このサイトは恐らく手書きでHTMLを書かれており、次の章へのリンクのある場合とない場合、あった場合でも意味のあるヒントがリンクについていないものでした。このようなサイトは仕組み上対応は無理だとお考えください。
ということなのですが、個人サイトを名指しで「対応できない」と書くわけにもいきませんでしたのでサポートサイトのQ&A側ではなくこちらでのご報告で勘弁してください。

以上となります。
それでは、今後共 ことせかい をよろしくお願いいたします。


# Version 1.1.38

Bug fix

- Corrected a problem that the reading-out position might not return to the beginning when repeating playback


# Version 1.1.39

インタフェースの変更
- 「設定」タブの「開発者に問い合わせる」内の「報告への返事」を「不要」「無くても良い」「必須」の選択式に変更

問題の修正
- 「ルビはルビだけ読む」機能で、 |...《...》 の形式のルビにおいて、｜(全角) には反応していなかった問題を修正

アップデートをすると不都合報告が届く量が増え、指摘された所を直してまたアップデートして不都合報告が届いて……というサイクルに入ってそうだなぁと思っている開発者です。こんにちは。

先日からの続けてのアップデートで、不都合報告や改良案のご提案などのお問い合わせが増えています。恐らく今回のリリースでもお問い合わせが増えるのでしょう。
お問い合わせを受けること自体はどちらかというと嬉しいのですが、お返事を差し上げるためのメールアドレスが記述されていないお問い合わせの多くは、残念なことに書かれている情報が少なすぎて対応ができないものが多くなっています。そこで、先日よりご意見ご要望フォームでのお問い合わせではメールアドレスを必須としました(一応「絶対に返信はしないでほしい」という選択肢も増やしましたのでシャイな方はそれを選んでお問い合わせください)。

また、前々回のリリースで告知しました通り、先日より ことせかい のβテスターを募集しています。募集要項等の詳細についてはサポートサイト下部のリンクから御覧ください。

このβテストの目的は、リリース候補版をβテスターの方々に先行して使って頂いて、目につく不都合があれば報告してもらい、正式なリリースの前にその目につく不都合をへらす事で大量の不都合報告で開発者が疲弊するという自体を避ける、というものです。つまり、このβテストの試みはβテスターさん達の数にかかっています。しかし正直な所、今集まっているテスターさん達の数では全く足りません。これくらいの数しか居ないのであればβテストの期間を取るだけ無駄と言ってもいいと思います。皆様の積極的な参加を希望します。
βテスターの方々の人数が少ないなどでβテストの試みに効果がない場合、βテスターさん達は無駄働きになり、リリース間隔は伸び、開発者側の負担も増えるという全方位全てに損しかありません。

開発者としてはこの問題はかなり大きくて、例えばメールが届くたびにビクビクしていて、開いたメールは別件だったのにしばらく動悸が収まらなかったりとなにやらトラウマでも抱えてしまっているようです(医者にかかったわけでもないのでなんとも言えませんが)。概ねの所それが原因で、開発者は ことせかい の開発に元気が出せない状態になっています。そのため、「この問題はユーザの数が多い事に起因している。ユーザの数が増えると期待していない動きを見せるユーザの数も比例して増えるからだ。これを回避するのに例えばアプリをストアから消してしまえばいいのでは、あぁでも既にダウンロードされている人から報告が来るかもしれないからいっそのことそれらの人も減らすために月額制に変えてしまえばいいのでは」というような事を真面目に考えています。別にお金がほしいわけではないのでユーザが完全にいなくなるような高額に設定すればいいか、など妄想は膨らんでいます。

開発者の素直な気持ちとしては、ことせかい は MITライセンス で公開している趣味のアプリであるので(全文はアプリ内の設定タブにあります「ことせかい 利用許諾」をお読みください)、『ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、何らの保証もなく提供されます。』という事を納得して使って頂くならそれを咎める気は全くなく、どちらかというと是非使ってほしい位です。逆に、不都合を出したらそれがトリガとなってボコボコに叩かれるというのは"現状のまま"に納得せずに使っているということになり、それなら文句を言う前に自分で問題を解決して pull request するなり fork して自分なりに改変して使うなり使うのをやめるなりすればよく、それでも直接文句を言いたいのならご意見ご要望フォームなどに出している「その問題は既に解消済みなので報告の必要は無く、Appleの審査待ちなのでしばらく待って欲しい」という告知文位は読んでから不都合報告をすべきであり、それもできないのであればライセンスにかかれている「"現状のまま"提供される」という事に納得していない、つまりライセンス違反なので使ってほしくない、という気持ちです。

と、いうことなので前述のような「ユーザよいなくなれ」と考えてしまっているような形になっています。
とはいえ、開発者としましては別にユーザ様達を嫌っていて嫌がらせをしたいわけではなく、何も言わずに使って頂ければそれでよく、喜んで使っていただけるのなら嬉しくなります。それに、今まで便利に使っていたものが使えなくなるのはユーザ様としても嬉しくはないでしょう。で、あるならば、どういう事をすると良いのかという話になるのですが、開発者側でできるような事は色々やりましたがそこまで効果は認められずに現在に至っています。という事なので、開発者のみではどうにもできそうにないのでユーザ様達の力をお借りしたい、という次第です。何卒ご協力をよろしくお願いいたします。

さて、これだけ長々とご意見ご要望を送ってこられると辛い、みたいな話をしているとご意見ご要望を出したいけれど出しちゃ駄目なのかな、と考えてしまう方が出てくるかと思うのですが、多分そういう事を考えられる方はそんな事を気にせずにご意見ご要望を送ってくださって構わないと思います。開発者が嫌がっているのは概ね

- 同じ不都合の報告が山程届く(丁寧または普通の言い方でも数が増えると「もうその話題はいいです。間に合ってます。既に直しました。文句はAppleに言ってください」という気分にしかなりません)
- 言い方がきつい場合(開発者も人の子なのでカチンと来ます)
- 不都合報告ではあるのだが情報量が皆無で「不都合が起きた」という事実しかわからず再現もできず問題を解消できない場合(不都合があったことはわかるが直そうにも直せないのは辛いです。また、返信ができるのであれば開発者側から詳しい状況を確認する旨のお返事ができますのでだいたいは問題を特定できます。なので返信ができないのはかなり問題です)

というものです。なので、

- 不都合報告をする場合はご意見ご要望フォームに時々追加されている「追記」を読んで現在報告しようとしている問題が書かれていないかを確認する
- 丁寧な文面で書く
- 返信を可(又は必須)にしておく

という辺りを守って頂ければ問題ないかと思います。というより、上記の点に留意されているご意見ご要望は癒やしとなりますので是非送ってください。

長くなりました。このくらいにしておきます。
それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.39

Interface change
- Change "Reply to report" in "Send inquiries to developers by e-mail" on "Settings" tab to selection formula of "unnecessary" "no need" "essential"

Fixing problems
- "Ruby reads ruby only" function, which fixes a problem which was not responding to ｜ (double-byte) in ruby of  |...《...》 format


# Version 1.1.40

問題の修正

- 「小説を読む時に背景を暗くする」がONになっているときに、小説本文のスクロールバーが見えなくなっていた問題を修正

追伸

今回は軽微な修正のみとなります。

今回修正をした「小説を読む時に背景を暗くする」機能については、開発者は全然使っていないものになりますので色々と確認漏れが発生しているような気がしています。ということなので「何故こうなっている(又はなっていない)のだろう」という疑問点などありましたら(「小説を読む時に背景を暗くする」機能以外についてでも)ご意見ご要望フォーム等からお知らせして頂ければと思います。

また、前回の追伸でβテスターさんを募集したところ、何名か応募していただける方が増えました。ありがとうございます。ただ、まだまだ全然足りませんのでお手伝いいただける方はよろしくお願いいたします。

さて、手短になりますが今回はこのくらいにしておきます。
それでは、これからも ことせかい をよろしくお願いいたします。



# Version 1.1.40

Bug fix
- Fixed an issue in which the scroll bar of the novel text disappeared when "Darken the background when reading a novel" was ON


# Version 1.1.41

インタフェースの変更

- 「読みの修正」で正規表現による読み替えができるように
- 「読みの修正」でのテスト読み上げの時に「声質の設定」の標準設定を使うように
- 内部データベースの保存場所を移動しました

今回は読みの修正で正規表現が使えるようになるという変更を加えました。簡単に言うと今までの読み替えよりも複雑な読み替え指定ができるようになるのですが、正規表現という言葉に聞き覚えの無い方には多分難しいと思われますので「分かる人だけ使ってください」としておきます。

その分かる人向けの情報になりますが、正規表現周りは NSRegularExpression を使っており、NSRegularExpression で利用可能なメタキャラクタ、オペレータを利用可能になります。
https://developer.apple.com/documentation/foundation/nsregularexpression#1965589
例えば、"()" でキャプチャした文字に対して "$数字" による参照ができるようになり、"(\P{Han})己" を "$1おのれ" と読み替えるように登録すると、"自己" は "じこ" のまま、"太郎は己の" を "たろうはおのれの" と読み替えるような指定をしたことになります。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。ただ、残念ながらテスターの数が全く足りていません。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。何度もお願いしてしまって恐縮なのですが、お手伝い頂ければ幸いです。
なお、このβテスト等の試みがうまくいかないまま、次に「不都合が出た等の原因で色々言われた」であるといったような心が折れる事が起きた時には ことせかい というアプリは終わりにしようと思っている事はお伝えしておきます(例えば誰も払いたくなくなる位の高額な月額制にするとかそういう形での 終わり です)。
頑張ってくださいやご自愛ください的な応援は十分頂いております。ありがとうございます。ただ、どちらかというと求められているのは具体的な行動による支援であり、口だけの応援ではないことを理解して頂ければ嬉しいです。

それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.41

Interface change

- In order to be able to read by regular expression in "Correction of reading"
- To use the standard setting of "Voice quality setting" when reading the test in "Correction of reading"
- The internal database storage location has been moved

# Version 1.1.42

インタフェースの変更

- キーボードが出るシーンにおいて、キーボードが閉じられない場合があったのを改行を入れるなどで閉じられるように変更

今回はキーボードが消えない問題(特に iPhone 5s 等の画面が小さい端末で問題になっていました)に対処しました。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。ただ、残念ながらテスターの数が全く足りていません。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。何度もお願いしてしまって恐縮なのですが、お手伝い頂ければ幸いです。
なお、このβテスト等の試みがうまくいかないまま、次に「不都合が出た等の原因で色々言われた」であるといったような心が折れる事が起きた時には ことせかい というアプリは終わりにしようと思っている事をお伝えしておきます(例えば誰も払いたくなくなる位の高額な月額制にするとかそういう形での 終わり です)。
頑張ってくださいやご自愛ください的な応援は十分頂いております。ありがとうございます。ただ、どちらかというと求められているのは具体的な行動による支援であり、口だけの応援ではないことを理解して頂ければ嬉しいです。


それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.42

Interface change

- In the scene where the keyboard comes out, the keyboard may not be closed In some cases it is changed so that it can be closed by putting a line feed etc.


# Version 1.1.43

インタフェースの変更

- 標準の読み替え辞書にいくつかの正規表現を使った設定を追加
- iOS 12 において、読み上げ中の文字の表示位置がおかしくなる場合がある問題への暫定的対処のON/OFF設定を追加
- iPhone X 等のノッチのある iPhone で、ダウンロード中の表示が画面上部のインジケータに出なくなっていた問題に対処

問題の修正

- 設定タブの読み上げ時の間の設定 で、個別の設定を変えたり追加した後に読み上げ時の間の設定に戻ってもそれらの変更が反映された表示にならない問題を修正

追伸

iOS 12 になった後に読み上げ中の文字の表示位置がおかしくなる問題が確認されたのでその問題の一部に対して暫定的に回避する仕組みを追加しました。
この問題は読み上げ位置の表示がおかしくなる(読み上げられている位置よりも前の位置を表示してしまう)というものなのですが、その読み上げ位置がおかしくなった状態で読み上げを停止させて、再度再生させようとした時にはそのおかしくなってしまった読み上げ位置から読み上げを再開してしまうという問題を誘発してしまいます。問題の原因としては、iOS 12 で iOS が提供している音声合成エンジンの動作が変わった事によるものだと思われます。
一応 Apple の Bug Reporter を使って該当の問題が再現する検証用 source code も添付してのバグ報告をしましたが、おそらくこの Bug Reporter は毎日途方もない量のバグレポートが届いていてその中に埋もれてしまうと思われますのでそうそうすぐには直らないような予感がします。
それでこの問題への対策なのですが、かなり強引な手法で行うものになりましたので設定タブの中の一項目としてON/OFFをユーザ様側で制御して頂く形にしています(標準ではOFFとなっています)。
というのは、この問題は「空白のような(読み上げられない)文字を含んでいる文を読み上げようとする」と発生するということのようであるのですが、その問題を起こす文字を別の文字に置き換えて発話させることで回避できる"ことがある"という事を発見したため、回避策として読み上げに利用する文字について、問題が起こりそうな文字を別の文字に置き換えた物を利用する、という形で実装しています。ただ、この発話されない文字というのが曲者で、例えば空白は発話されないわけですが空白は読み上げ位置がずれてしまう可能性のある文字であり使えず、句読点も読み上げられませんが不必要な読み上げの間が発生してしまい使えず、"_" といった通常時は読み上げられない文字を指定すると、前後の文字によっては時々読み上げられてしまうという問題があり…… となっていて、その中で多分これなら大丈夫(読み上げられない)と思われる文字として"α"(アルファ)を使っています。と、いうことで、このオプションをONにすると空白や改行などの文字が "α" として読み替えられるようになります。なので、将来的に iOS の音声合成エンジン が "α" を「アルファ」と読み上げる様になってしまった場合にはこの設定がOFFに戻して運用してください、という意味でON/OFFができるようにしています。
なお、この文章を書いている時点で確認されている読み上げ時の表示位置がおかしくなる例についてはほぼ全て対応できていると思うのですが、恐らくは対応できていない場合も残っているかと思われます。なのですが、上記のような回避策での実装となっておりますので完璧はありえないとご理解ください。

次に、iPhone X 等のノッチのある iPhone ではダウンロード中に画面上部に表示していたインジケータの領域がなくなってしまったそうで、ダウンロード中の表示が全く表示されない状態だったそうです。そこで、FTLinearActivityIndicator というライブラリを使って iPhone X では画面右上に左右に揺れるインジケータを表示するようにしました。ただ、これは ことせかい が起動中のみの表示となりますのでご注意ください(ことせかい がバックグラウンドに回った時でも表示できるようなやり方があれば教えてください)。

それから、何度も書いてしまって申し訳ないのですが、『不都合報告をする時には返信を許可の状態で報告することをおすすめします』不都合報告のほぼ全てにおいて、情報が足りず開発者側で同様の事象が再現できずに対応ができないため、折返し細かい情報のヒアリングの質問を開発者側から送らせていただく事になっています。ですので、返信を許可しないという状態で不都合報告を行った場合はその報告は無駄になることが大半であるということを理解した上で行ってください。

また、返信を許可していただいていたので折返しヒアリングの返信をした方で、そのメールには返信が頂けずに次々と別件の不都合報告をしていただく方などがおられます。このような場合もヒアリングへの返事を頂けないために対応ができない状態である事が大半であり、結果的には返信を不許可にして報告頂いたのと同じ状態(つまり対応できない状態)になる可能性が高いです。これは報告者にも開発者にも嬉しくない(開発者側としては返信を書いている時間が完全に無駄なのでどちらかというと返信を不許可にしてもらったほうがまだマシなのではと愚痴りたくなる位には徒労感の多い)残念な不都合報告となっておりますので、返信先のメールアドレスに返信が来ていないかどうかはできるだけチェックするようにしていただけると嬉しいです。(なお、特別な場合を除いて返信はだいたいその日の夜には送れるように努力していますので参考にしてください)

ついでなので書いてしまいますが、不都合報告における再現方法が1,2行で済んだ場合、必要な情報が含まれていない場合が多いと考えてください。最近の悪い例では「読み上げ中に」というのがそれに当たります。これらの場合は折返し「何という小説のどのあたりを読ませたら起こったのか具体的な名前や場所を教えてください」とお返事する事になりました。恐らくは再現方法と言われても何を書いたら良いのかわからないのかと思うのですが、「ことせかい を起動した後、どのように操作したらその不都合を確認できるか」というのを「ことせかい を全く使ったことのない小学低学年の人でもできるように書く」と考えて頂ければと思います。例えば、「なろう検索ボタンを押して、〜と入力して、検索開始ボタンを押して、出てきた〜という小説を選択して、Downloadボタンを押して、本棚ボタンを押して、先程の〜という小説を選択して、**ページを開いて、〜という部分を長押しして選択して、Speakボタンを押して、〜という部分に差し掛かると〜」という感じです。この例の情報からは「なろう検索を使っている」「〜という小説」の「**ページ」の「〜という部分から〜という部分当たり」に問題がありそうという事が読み取れます。大方の場合、そこまで状況を指定していただかないと同じ問題は発生させられません。例えば違う小説や同じ小説でも違うページだったりすると再現しなかったりするわけです。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。おかげさまで、βテスターの方々の数は順調に増えてきておりますが、まだまだ十分とはいえなさそうなのでお手伝い頂ければ幸いです。
なお、この ことせかい βテスター の募集は「発見されやすかったり、致命的だったりする問題が入ったままのものをAppStoreにリリースしてしまった場合に開発者に不都合報告が山程届くのを防ぐ」というのが主目的です。「テスターになったからには全ての問題を発見して報告する」というようなつもりで動いてもらう必要はありません(というかそうされるなら別にテスターにならずに普通にご意見ご要望フォームからお問い合わせくださっても変わりません)。というか、テスター向けに配信される ことせかい をざっと使ってみて、問題なさそうであれば「問題なし」と報告していただけるだけで結構です。その「問題なし」という報告が集まることで、「まぁだいたい沢山の人が問題ないと言っているということは、『発見されやすかったり、致命的だったりする問題』は無いのだろうからリリースしてしまっても『開発者に不都合報告が山程届く』事はあるまい」という判断ができるようになります。逆に、すぐに気づくような不都合があったときには「不都合あったよ」と報告していただけると、「あぁ、AppStoreにリリースする前にその不都合に気づかせてもらってよかった。ありがとうございます。直します」となりますのでそれはそれで(開発者に不都合報告が山程届くことがなく)安心になります。
ということなので、(不都合をみつけてしまった場合はその報告に不都合の詳細を書いたりする手間が大きくなりますが)すぐに見つかるような不都合が無い事を確認して報告するだけであればそんなに負担なくβテストに参加できるような気もしなくもありませんのでお手伝い頂ければ幸いです。
また、参加して頂いているβテスターの方々にはとても助けられています。ありがとうございます。中にはとても詳しい不都合報告を上げてくださる方などもおられまして、本当に有り難いです。ありがとうございます。

さて、今回はこれで以上となります。
それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.43

Interface change

- Added setting using several regular expressions in standard replacement dictionary
- Added ON / OFF setting for provisional countermeasure to problems that may be incorrect at the display position of the character being read at iOS 12
- Dealing with the problem that the indication being downloaded does not appear on the indicator at the top of the screen on an iPhone with a notch such as iPhone X

Bug fix

- Fixed a problem that the display reflecting those changes did not appear in the setting between reading aloud on the setting tab, even after changing individual settings or after returning to the settings between reading aloud after adding them


# Version 1.1.44

インタフェースの変更

- 設定 -> 読みの修正 で個々の変換ルールをタップすると詳細画面に移行するように

不都合の修正

- HTTP 200 OK 以外でダウンロードが成功していた場合があった問題を修正
- 空白や空行のみといった表示されない文字だけの本文が読み込まれた場合にもダウンロードが失敗したことと判定するように

追伸

先日、アルファポリス様 からのWeb取込でのダウンロードで、内容がカラのものが取得されてしまう、という報告を受けました。この問題は恐らくは アルファポリス様側 の仕様変更によるもので、ことせかい の側としては対応するのが難しい問題と考えられます(少し詳しい情報についてはサポートサイト下部のリンクにありますQ&Aをご参照ください)。ということですので、アルファポリス様については今後はWeb取込が難しいサイトであるとお考え頂けると嬉しいです。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。おかげさまで、βテスターの方々の数は順調に増えてきておりますが、まだまだ十分とはいえませんのでお手伝い頂ければ幸いです。
なお、このβテスト等の試みがうまくいかないまま、次に「不都合が出た等の原因で色々言われた」であるといったような心が折れる事が起きた時には ことせかい というアプリは終わりにしようと思っている事をお伝えしておきます(例えば誰も払いたくなくなる位の高額な月額制にするとかそういう形での 終わり です)。
頑張ってくださいやご自愛ください的な応援は十分頂いております。ありがとうございます。ただ、どちらかというと求められているのは具体的な行動による支援であり、口だけの応援ではないことを理解して頂ければ嬉しいです。
また、参加して頂いているβテスターの方々にはとても助けられています。ありがとうございます。中にはとても詳しい不都合報告を上げてくださる方などもおられまして、本当に有り難いです。ありがとうございます。

それから、こちらも何度も書いてしまって申し訳ないのですが、『不都合報告をする時には返信を許可の状態で報告することをおすすめします』不都合報告のほぼ全てにおいて、情報が足りず開発者側で同様の事象が再現できずに対応ができないため、折返し細かい情報のヒアリングの質問を開発者側から送らせていただく事になっています。ですので、返信を許可しないという状態で不都合報告を行った場合はその報告は無駄になることが大半であるということを理解した上で行ってください。

また、「アップデートしたら直りました」という内容のお問い合わせを送って頂けるのはうれしいのですが、不都合報告として送るのは避けて頂けますとありがたいです。お問い合わせは私にメールで届くんですけれど、メールって届いた時は表題しかみえないので、表題が「不都合報告」になっているメールが届くと気分が一気に谷底に落ちて、それから元気を出して内容を確認するって感じになるので辛いのです。ですので、そのような場合にはメールのタイトルを変更するなどでご対応して頂ければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.44

Interface change

- By tapping individual conversion rules with Settings -> Correction of the reading.

Bug fix

- Fixed an issue where sometimes the download succeeded except for HTTP 200 OK
- Judge that the download has failed even if the body of only characters that are not displayed such as blanks or blank lines are read


# Version 1.1.45

インタフェースの変更

- 文章を表示している画面のスライドバーの最大値を、ダウンロードされている章(ページ)の数に変更
- 最大連続再生時間を超えて再生が停止する時にそのようにアナウンスをするようになります
- バージョン更新時のダイアログを消した後でも最後に読んでいた小説を開くように
- 起動直後の一回だけ、最後に読んでいた小説が一番上に表示されるように本棚の表示位置が移動されるるように
- 本棚の左上に検索ボタンを配置

問題の修正

- 最大連続再生時間のカウントダウンが、読み上げ中にページ切り替えが発生した時にリセットされていた問題を修正
- 読み上げ中にイヤホンジャックからイヤホンを引き抜いた時に、再生位置がかなり前に戻ってしまう問題を修正
- ページめくりの時に鳴る音の扱いを、システムサウンドからアプリ側サウンドに変更
  - アプリ側サウンドになった影響により、読み上げ中以外ではページめくり音が出ないように
- 本文上で長押しして出てくる「読み替え辞書へ登録」を押した後の読みの修正詳細にて、読み替え前の文字列を選択されていた文字で初期化するように


追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回はちょこちょこと修正していたものが色々溜まってしまってちょっと変更点が多めになりました。

ダウンロード中の小説の、まだダウンロードされていない部分を開くことができないようにするという修正になります(これは、ダウンロード中という事がわかりにくかった事による「表示できない部分があるのは不都合なので直せ」といったお問い合わせが減る事を期待しています)。

また、「設定」->「連続再生時間」がうまく効いていない場合があった問題も修正しまして、ついでに設定された連続再生時間を超えた時にはそのようにアナウンスを入れるようにしました。

他にも、使っていて気になっていた部分に少し手を入れています。

後は少し安定性を高めるための修正も施しているのですが、根本的な原因を突き止めてのものではありませんので特にリリースノートには書かないでおくことにします(βテスト用の方の情報には載っていますので興味のある方はそちらを読んでみても良いかもしれません)。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。おかげさまで、βテスターの方々の数は順調に増えてきておりますが、最近はβテスターの方たちの数に比べて報告を上げて頂ける方の数が減っておりまして、十分とはとてもいえない状態になっておりますのでお手伝い頂ければ幸いです。
また、βテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

また、これから開発者がガッツリと遊びたいゲームが出る事になっていたりするなど ことせかい 以外の事ももう少し多めにやりたいなぁと思いますので、しばらくの間は ことせかい の開発については不都合の修正を主とする感じでやんわりと続ける感じで行きたいと思っています。そんなわけなので、お問い合わせへの対応が遅くなったりする事や新機能の実装があまりされない事などが発生するかもしれません事をご了承ください。

それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.45

Interface change

- Change the maximum value of the slide bar of the screen displaying sentences to the number of chapters (pages) being downloaded
- When playback stops beyond maximum continuous playback time, NovelSpeaker will announce that way
- Even after erasing the dialog at the time of version update, it opens the novel that was last read
- The display position of the bookshelf is moved so that the novel which was being read last is displayed at the top, only once after activation

Bug Fix

- Fixed problem that countdown of maximum continuous playing time was reset when page switching occurred during reading
- Fixed a problem that the playback position got back a long way back when the earphone was pulled out of the earphone jack during reading
- Change the handling of the sound that sounds when page turning from system sound to application side sound
- In the main revision details after pressing "Register to replacement dictionary" coming out with long press in the text, so that the character string before replacement is initialized with the selected character
- Turn off page turning sound except during reading aloud

# Version 1.1.46

インタフェースの変更

- 設定 -> 他のアプリで音楽が鳴っても止まらないように努力する の ON/OFF 設定を追加

問題の修正

- 設定 -> ルビはルビだけ読む の ON/OFF を切り替えた前後で開いていた小説のページが変わらないまま読み上げを開始するとその設定が反映されない問題を修正
- 設定 -> ルビはルビだけ読む でルビとして判断される基準を少し変更
- Web取込 で取り込んだ小説が多めにある時に、本棚で全ての小説のダウンロードを開始してしばらくすると落ちる問題の一部を修正
- 小説本文が表示される時など、読み上げていない時に別アプリがバックグラウンド再生している音楽等が止められる可能性がある問題に対応
- 設定 -> 小説の自動更新 を ON から OFF に切り替えた時に、実際は自動更新が停止していなかった問題を修正

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

さっそく不都合修正です。(´・ω・`)
ことせかい でのルビの判定は 小説家になろう様 の定義( https://syosetu.com/man/ruby/ )をもとにしているのですが、この定義には無い形式のルビ記法でもルビとして判断されるものがあるようなのでそれに対応したのと、今まではルビを振られる文字もルビとして振り替えられる文字も長さに制約はなかったのですが、定義にはそれぞれ10文字までと書いてある事に気づいたのでその定義に従って10文字までしか反応しないようにした、という変更になります。また、ルビとして判断しない文字の標準値を少し変更しています。

他に、ミュージックアプリで音楽を聞きながら ことせかい での読み上げもして欲しいというお問い合わせがありましたので、それをできるようにする ON/OFF 設定 を追加しました。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。おかげさまで、βテスターの方々の数は順調に増えてきておりますが、最近はβテスターの方たちの数に比べて報告を上げて頂ける方の数が減っておりまして、十分とはとてもいえない状態になっております。このままお手伝いしていただける方が減り続けますと、リリースサイクルがさらに遅くなったり、最悪不都合つきのリリースをしてしまうことで非難轟々になって開発者がやる気を無くしてアプリが終了、といった事がありえますのでお手伝い頂ければ幸いです。
また、βテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

また、これから開発者がガッツリと遊びたいゲームが出たりするなど ことせかい 以外の事ももう少し多めにやりたいなぁと思いますので、しばらくの間は ことせかい の開発については不都合の修正を主とする感じでやんわりと続ける感じで行きたいと思っています。そんなわけなので、お問い合わせへの対応が遅くなったりする事や新機能の実装があまりされない事などが発生するかもしれません事をご了承ください。

それから、今現在の ことせかい は iOS 8 以降で動作するのですが、近い内(だいたい年内位を目標)に iOS 9 か iOS 10 以降当たりでないと動作しないようにビルド設定を変えようかと思っています。これは、使っている外部ライブラリの対応OSバージョンが上がってしまっていて最新版に追いつけていないっぽいというのと、便利そうな外部ライブラリが iOS 8 では動かないので組み込みにくいという当たりが原因となります。ということなので、このバージョンはまだサポートしておいて欲しいという要望のある方は「その理由も添えて」サポートサイト下部にありますご意見ご要望フォームなどからお知らせください。理由によっては考慮致しますが、あまり期待しないでください。

それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.46

Interface change

- Add "Settings" -> "Effort not to stop even if the music sounds in other applications" option

Bug fix

- Fixed a problem that setting will not be reflected if you start reading aloud the page of the novel that was open before and after switching Settings -> Speech ruby only ON / OFF
- Settings -> Speech ruby only slightly changed criteria judged as ruby
- Fixed a part of the problem that started when downloading all the novels in the bookshelf after a while when there were a lot of novels imported by Web Import and falls for a while.
- Fixed a problem that there is a possibility that music that is being played back in the background by another application is stopped when the novel text is displayed
- Fixed the problem that automatic updating was not actually stopped when Settings -> Auto download for updated novel changed from ON to OFF


# Version 1.1.47

問題の修正

- なろう検索 経由での小説本文のダウンロードが失敗するようになった問題に対応

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回は2018年12月18日辺りから「なろう検索」経由での小説本文のダウンロードが失敗するようになった問題への対応になります。
これは、今までは 小説家になろう様 の TXTダウンロード の機能を利用してダウンロードさせていただいていた部分を、Web取込と同じ仕組みで取り込むように変更する形の対応になります。そのため、今までの形式と少し違う本文の取り込まれ方になるかと思いますのでその辺りはご了承ください。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。おかげさまで、βテスターの方々の数は順調に増えてきておりますが、最近はβテスターの方たちの数に比べて報告を上げて頂ける方の数が減っておりまして、十分とはとてもいえない状態になっております。このままお手伝いしていただける方が減り続けますと、リリースサイクルがさらに遅くなったり、最悪不都合つきのリリースをしてしまうことで非難轟々になって開発者がやる気を無くしてアプリが終了、といった事がありえますのでお手伝い頂ければ幸いです。
また、βテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

また、これから開発者がガッツリと遊びたいゲームが出たりするなど ことせかい 以外の事ももう少し多めにやりたいなぁと思いますので、しばらくの間は ことせかい の開発については不都合の修正を主とする感じでやんわりと続ける感じで行きたいと思っています。そんなわけなので、お問い合わせへの対応が遅くなったりする事や新機能の実装があまりされない事などが発生するかもしれません事をご了承ください。

それから、今現在の ことせかい は iOS 8 以降で動作するのですが、近いうちに iOS 9 か iOS 10 以降当たりでないと動作しないようにビルド設定を変えようかと思っています。これは、使っている外部ライブラリの対応OSバージョンが上がってしまっていて最新版に追いつけていないっぽいというのと、便利そうな外部ライブラリが iOS 8 では動かないので組み込みにくいという当たりが原因となります。ということなので、このバージョンはまだサポートしておいて欲しいという要望のある方は「その理由も添えて」サポートサイト下部にありますご意見ご要望フォームなどからお知らせください。理由によっては考慮致しますが、あまり期待しないでください。

それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.47

Bug fix.

- Corresponds to problems that downloading of novel text via Search fails


# Version 1.1.48

インタフェースの変更

- 読み上げの話者が未設定の場合、標準のもの(kyoko)ではなく利用可能な中でリッチな話者を選択するように
- iOS 10 以降の対応に変更(以前は iOS 8 以降でした)
- 設定 -> 起動時に前回開いていた小説を開く のON/OFF設定を追加
- 設定 -> 小説の自動更新 が ON になっている時の更新通知に更新された小説名を追加

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

以前から案内しておりました通り、今回のリリースから対応する iOS のバージョンを iOS 8 から iOS 10 に上げさせていただきました。

また、起動時に前に読んでいた小説が開かれないようにして欲しいというご要望がございましたのでその目的のためのON/OFF設定を追加しました。ただ、ことせかい を開いた時に、前回読みかけであった小説を Speak ボタンを一回押すだけで再開可能であるという利便性を捨てる変更になってしまうのは忍びなかったので、前回の起動時に開いていた小説を読み終えていなければ(又は読み終えていたとしても起動していない間に更新されていれば)本棚画面下部に前回の小説の再生を行うためのボタンが出るようにしました。このボタンを押しますと示されている小説の再生が開始されますので音を出してはまずいような所でご使用の場合は注意してください。

他に、ことせかい をインストールしただけですと話者の設定がKyokoのようなあまり聞き取りやすくない話者が選択されたままになっていて、そのまま話者を変更できることを気づかずに使われている方がいそうな気がしましたので、話者が未設定の場合にはできるだけ聞き取りやすそうな発話を行う話者が選択されるように変更しています。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。なお残念ながら最近はテストの結果報告をして頂ける方の数が減っておりまして、十分とはとてもいえない状態になっております。具体的にはここ2ヶ月の間は新たなβテスターの方は増えておらず、βテストの結果報告をされる方も順調に減っております。また、当初は登録されたβテスターの方々の半数以上が結果報告をしていただけていましたが、今では1割とちょっと位の数の方からしか報告が上がってこない状態です。このままお手伝いしていただける方が減り続けますと、リリースサイクルがさらに遅くなり、最悪不都合つきのリリースをしてしまうことで非難轟々になって開発者が(既になくなりかけている)やる気を(完全に)無くしてアプリが終了、といった事になりそうです。どうしたものですかね。
また、結果報告を精力的にして頂けているβテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。



# Version 1.1.48

Interface change

- If you do not set speakers to read aloud, select a rich speaker that is available instead of the standard one (kyoko)
- Changed to support iOS 10 or later (previously iOS 8 or later)
- Added ON / OFF setting to "Setting -> Open recent book in start time"
- Added updated novel name to update notification when setting -> novel automatic update is ON


# Version 1.1.49

インタフェースの変更

- HTML上のルビ(rubyタグ)を取り込む時には一律で "|文字(ルビ)" の形式で読み込まれるようにすることで、「ルビはルビだけ読む」がより意図通りに動作するように

追伸

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回はルビの取り込み方を少し変えました。この修正は rubyタグつきの文字列が「ドラゴン殺し(ドラゴンスレイヤー)」といった文字列で読み込まれてしまうことで、「どらごんごろしどらごんすれいやー」と読み上げられてしまう問題を読み込みの時点で「|ドラゴン殺し(ドラゴンスレイヤー)」という文字列で読み込むことで回避しようという目的のものです。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。なお残念ながら最近はテストの結果報告をして頂ける方の数が減っておりまして、十分とはとてもいえない状態になっております。具体的にはここ3ヶ月の間新たに応募していただいたβテスターの方は一人のみで、βテストの結果報告をされる方も順調に減っております。また、当初は登録されたβテスターの方々の半数以上が結果報告をしていただけていましたが、今では1割とちょっと位の数の方からしか報告が上がってこない状態です。このままお手伝いしていただける方が減り続けますと、リリースサイクルがさらに遅くなり、最悪不都合つきのリリースをしてしまうことで非難轟々になって開発者が(既になくなりかけている)やる気を(完全に)無くしてアプリが終了、といった事になりそうです。どうしたものですかね。
また、結果報告を精力的にして頂けているβテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.49

Interface change

- When loading ruby (ruby tag) in HTML, by reading it in the form of "| character (ruby)" uniformly, so that "ruby reads only ruby" works more as intended

TODO


# Version 1.1.50

インタフェースの変更

- 「なろう検索」タブの削除方針に則り、「なろう検索」タブにて告知を開始

問題の修正

- Web取込機能において、同じページを読み込み続けてしまう可能性のある問題を修正

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回は残念なお知らせがあります。ことせかい の初回リリース時より便利に使っていただいていた「なろう検索」タブ関連機能の削除予定のお知らせとなります。ただ、このアップデート告知文に書きますには少々文章量が長くなりすぎますので、サポーサイト下部からリンクされております Q&A に「なろう検索 タブ等の削除方針について」として、なぜそのような判断に至ったのかという説明を追記しておきましたのでご参照下さい。
https://limura.github.io/NovelSpeaker/QandA.html#DeleteSearchTab
なお、このURLには なろう検索 タブに追加されました「なろう検索タブ削除(予定)のお知らせ」から飛ぶこともできます。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。なお残念ながら最近はテストの結果報告をして頂ける方の数が減っておりまして、十分とはとてもいえない状態になっております。具体的にはここ3ヶ月の間新たに応募していただいたβテスターの方は3人のみで、βテストの結果報告をされる方も順調に減っております。また、当初は登録されたβテスターの方々の半数以上が結果報告をしていただけていましたが、今では1割とちょっと位の数の方からしか報告が上がってこない状態です。このままお手伝いしていただける方が減り続けますと、リリースサイクルがさらに遅くなり、最悪不都合つきのリリースをしてしまうことで非難轟々になって開発者が(既になくなりかけている)やる気を(完全に)無くしてアプリが終了、といった事になりそうです。どうしたものですかね。
また、結果報告を精力的にして頂けているβテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.50

Interface change

- Start announcing on the Search tab according to the deletion policy of the Search tab

Bug fix

- Fixed a problem that continued loading of the same page in Web capture function


# Version 1.1.51

インタフェースの変更

- Web取込 機能側での一回で取り込まれる小説の章の数の最大値を100から1000に増加
- ルビはルビだけ読む 機能でルビとして判断される文字列の扱いを少し変更

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正は小説の取り込み時にかけていた一回の最大読み込み話数の制限を100話から1000話に増加したものと、「ルビはルビだけ読む」機能でルビを振られる文字列やルビの文字列の長さが11文字以上になるものにも対応したという二点になります。

また、以前のリリースノートでも告知しました通り、ことせかい の初回リリース時より便利に使っていただいていた「なろう検索」タブ関連機能が削除予定になりますことを重ねてお伝えしておきます。
詳しくはサポーサイト下部からリンクされております Q&A に「なろう検索 タブ等の削除方針について」として、なぜそのような判断に至ったのかという説明を追記しておきましたのでご参照下さい。
https://limura.github.io/NovelSpeaker/QandA.html#DeleteSearchTab
なお、このURLには なろう検索 タブに追加されました「なろう検索タブ削除(予定)のお知らせ」から飛ぶこともできます。
今の所本件に関しては概ねご理解を頂けていますようで、ありがとうございます。また、効力のありそうな改善案なども頂いておりませんので、粛々と準備を行ってそれなりに近い内に実行に移そうかと思っています。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。なお残念ながら最近はテストの結果報告をして頂ける方の数が減っておりまして、十分とはとてもいえない状態になっております。また、当初は登録されたβテスターの方々の半数以上が結果報告をしていただけていましたが、今では1割とちょっと位の数の方からしか報告が上がってこない状態です。このままお手伝いしていただける方が減り続けますと、リリースサイクルがさらに遅くなり、最悪不都合つきのリリースをしてしまうことで非難轟々になって開発者が(既になくなりかけている)やる気を(完全に)無くしてアプリが終了、といった事になりそうです。どうしたものですかね。
また、結果報告を精力的にして頂けているβテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.51

Interface change

- Increase the maximum number of novel chapters captured at one time on the web capture side from 100 to 1000
- Ruby changes ruby string handling judged as ruby with ruby only reading function slightly


# Version 1.1.54

インタフェースの変更

- 新しい告知があった場合に 設定タブ にバッジがついたりして確認を促すように
- 設定 -> 開発者へ問い合わせる に「内部に保存されている操作ログを添付する」のON/OFF設定を追加

不都合の修正

- Web取込側で新しく小説を取り込んだ時に、本棚に小説が追加されていないように見えてしまっていた場合の有る問題を修正

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回は軽微な不都合修正と、ことせかい のお問い合わせ対応処理の省力化のための修正の二種類となります。不都合修正の方はそのままのものなので、お問い合わせ対応処理の省力化のための修正について少し書き下す事にします。
先日、iOS の音声合成エンジン側の更新がかかったようで、今まではそのままでは読み上げられていなかった「α」を「あるふぁ」と読み上げるように変更されたようです。このため、「設定」->「iOS 12 で読み上げ中の読み上げ位置表示がおかしくなる場合への暫定的対応を適用する」が ON になっていますと、空白などの部分において「あるふぁ」と読み上げられるようになってしまうという問題が発生しました。この問題についての詳しい情報はその「設定」->「iOS 12 で読み上げ中の読み上げ位置表示がおかしくなる場合への暫定的対応を適用する」を OFF から ON にしようとした時に出てくるダイアログを読んで頂ければわかるのですが、iOS 12 になった時に発生していた読み上げ時の読み上げ位置表示がおかしくなる問題(空白部分などをそのまま読み上げさせると音声合成エンジン側から通知される読み上げ位置がおかしくなる)に対応するために、読み上げ位置表示をおかしくる原因になっている空白等の部分を別の文字に置き換える必要があり、この置き換え先の文字として、当時は読み上げられなかった「α」を採用したという経緯があり、そのうち「α」を「あるふぁ」と読み上げられるようになった場合には良くないことが起こるだろうなぁと思ったので、ON/OFF ができるような設定項目とし、かつ、これを ON にする場合には告知文を表示してその上で ON を選択していただくことで「あるふぁ」と読み上げられるようになった時でもなんとか対応できるようになるといいなぁ、と思っていたわけです。
とはいえ、iOS 12 がリリースされましたのが去年の9月頃のはずで、この問題が発生したのが今年の8月位なわけで、1年弱も前の設定項目の長たらしい文章なんて皆さん覚えていませんよね。よくわかります。
そんな訳なので、これはお問い合わせが沢山来るだろうなぁと思いましたので、サポートサイトの上部のお知らせ欄(今回のようなお知らせがある場合、サポートサイトを開いた後少し待っているとその新しいお知らせが表示されます)や、サポートサイト下部から辿れるご意見ご要望フォームの上部、アプリ内の「設定」->「開発者に問い合わせる」の上部に追加されるお知らせ欄のそれぞれにおいて上記の問題についての対応方法(設定項目をOFFにする)をご案内するようにしました。
この対策はたしかに効果があったようで、サポートサイトのご意見ご要望フォームやアプリ内の「開発者に問い合わせる」からの本件についてのお問い合わせはかなり少なくなりました。しかし、AppStore側 には同様の動作が出ておかしいのでなんとかして欲しいというお問い合わせを書く方が不定期に現れる状況で、恐らくはこちらからのお知らせが届いていない方がおられるということが観測できていると感じられました。
そのため、今回の修正ではアプリを起動した時にお知らせを確認して、新しく読んだことのないお知らせがある場合には、設定タブの所にバッジがつくような形で新しいお知らせがある事を確認しやすくするようにしました。これで少しは新しいお知らせがある事に気づく方が増えれば良いなと思っています。(なお、読んでいないお知らせがある場合には起動時にダイアログが出るようにするような形での告知も考えたのですが、ユーザとしては意図しない1タップが不定期に入る事になり、利便性を損なうという理由で今回のようなバッジでのお知らせの形にしてみました。とはいえ、ダイアログが出るようにしたとしても、意図しない(文字数の多い)ダイアログは読まずに閉じる方はおられるでしょうし、今回の実装のようにバッジが出るようになってもそれを無視する方もおられるとは思うので、AppStoreのレビュー欄にお問い合わせを書いてしまう方(ひいては問題が発生していてもこちらからの告知を読んでいただけないために不満を抱えてしまわれる方を)完全に防ぐことはできないのだろうとは思っています。「お問い合わせを減らす」という目標の達成は終わりがなさそうで……えぇと……やりがいがあります……という事にしておきます)
蛇足となりますが、この文章を書いている時で、こちらの手元にある iOS端末 で「α」を「あるふぁ」と読み上げない端末も存在はしますので、単に全ての iOS端末 で「iOS 12 で読み上げ中の読み上げ位置表示がおかしくなる場合への暫定的対応を適用する」をOFFにするようなアップデートはできないであろうという事がわかっており、Appleさんも面倒くさい事をするなぁという気分になっています。(´・ω・`)

次に、以前のリリースノートでもお知らせしました通り、「なろう検索」タブを削除する作業を進めております。この修正は ことせかい 内部で利用しているデータベースを新しいデータベースに移行する時と同時に行われる予定です。この、新しいデータベースを利用した ことせかい では色々とできることが増える予定ですが、iCloud を使っての端末間同期に関しての実装(Apple Watch対応の根幹部分にもなっています)で少々手こずっているなどの問題があり、すぐには適用できない状態です。とはいえ、できれば今年中にはリリースできるといいなぁという気持ちで作業しておりますので、恐らく今年中にはその「なろう検索」タブが使えなくなったバージョンにアップデートがかかるという理解をしておいていただけますようお願いいたします。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。
また、結果報告を精力的にして頂けているβテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.54

Interface change

- When there is a new announcement, a badge is attached to the setting tab to prompt confirmation
- Added ON / OFF setting of "Attach operation log saved internally" to "Settings"-> "Contact developer"

Bug fix

- Fixed a problem that occurred when a new novel was imported on WebImport and it seemed that the novel was not added to the bookshelf


# Version 1.1.55

インタフェースの変更

- 読み込んだ章の最初と最後の空白や改行部分を削除するように
- 「設定」→「再ダウンロード用データの生成」のタイトルを「バックアップ用データの生成」に変更
- Web取込 で取り込んだ小説について、編集から章の削除ができないように

不都合の修正

- 自作小説を編集中に章の削除をしようとした時に、その削除した章が栞のはさまれた章だった場合にその章が削除されなかった問題を修正

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正は以下のような目的の修正となっています。
まず、「読み込んだ章の最初と最後の空白や改行部分を削除」するようにしたのは、「設定」→「本棚に栞の位置を表示する」が ON になっていて、最後に空白や改行が沢山ある小説があった場合、その小説の読み上げが終わった後に本棚部分での栞ゲージの表示が最後の部分まで読んだ表示(紫色)にならないという問題があったためです。これは、最後まで読んだかどうかを判定するのに栞の位置(読み上げ位置)がその小説の末尾から10文字以内にあるかどうか、という判定をしているのですが、空白や改行などの読み上げられない文字については読み上げ位置がそこまでは移動せずに、読み上げられる文字の所に栞の位置が設定されてしまうため、最後まで読んだ、という判定にならない、という問題があったためです。

次に、「設定」→「再ダウンロード用データの生成」のタイトルを「バックアップ用データの生成」に変更しましたのは、時々「ことせかい の内容をバックアップしたい」というお問い合わせや新機能のご提案がちらほら舞い込んできますので、多分「再ダウンロード用データ」というよくわからないものより「バックアップ用データ」という文言の方がわかりやすいのかなぁと言うことで変更する事にしました。

次に、Web取込 で取り込んだ小説について、編集から章の削除ができないようにしました。これは、Web取込で取り込んだ小説で、章を個別に削除されてしまっても、(現状保存されている情報だけでは)その章を再度ダウンロードすることができないため、混乱を招いてしまうためです。

また、以前のリリースノートでもお知らせしました通り、「なろう検索」タブを削除する作業を進めております。この修正は ことせかい 内部で利用しているデータベースを新しいデータベースに移行する時と同時に行われる予定です。この、新しいデータベースを利用した ことせかい では色々とできることが増える予定ですが、iCloud を使っての端末間同期に関しての実装(Apple Watch対応の根幹部分にもなっています)で少々手こずっているなどの問題があり、すぐには適用できない状態です。とはいえ、できれば今年中にはリリースできるといいなぁという気持ちで作業しておりますので、恐らく今年中にはその「なろう検索」タブが使えなくなったバージョンにアップデートがかかるという理解をしておいていただけますようお願いいたします。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。
また、結果報告を精力的にして頂けているβテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.55

Interface Change

- Remove blanks and newlines at the beginning and end of imported chapters
- For chapters imported by Web import, chapters cannot be deleted from editing

Bug fix

- Fixed an issue where when deleting a chapter while editing a self-made novel, the deleted chapter was not deleted if the deleted chapter was a trapped chapter

# Version 1.1.56

インタフェースの変更

- DarkMode へ対応しました
- 小説本文シーンに検索ボタンを追加
- 設定 -> 声質の設定にて、スライドバーの値を表示するように
- 設定 -> 携帯電話網ではダウンロードしないようにする の ON/OFF 設定を追加

問題の修正

- iOS 13 の日本語環境下においてアプリ名が ことせかい ではなく NovelSpeaker になっていたのを ことせかい になるように修正
- 読み上げ中は読み上げ位置表示の上に出るメニューを出さないように

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正は iOS 13 への対応や、ユーザ様からお寄せいただきました新機能のご提案を実装したものになります。

DarkMode への対応は iOS 13 以降でご利用頂けるようになりますが、この対応に応じて、様々な場所での背景色が変更されております。少し色味が変わったものなどがありますが、DarkMode対応での副作用としてご理解頂ければ幸いです。
次に、小説本文シーンに検索ボタンを追加してみました。これは、小説の特定の部分を探し出したいというご要望に対応するためのものになります。副次的な作用として、検索文字列を指定せずに検索を行う事で個々の章の最初の1行目を一覧しつつ、その章へ移動するという機能として使えなくもないような実装にしています。
次に、設定 -> 声質の設定で設定できるスライドバーによる値を数値として見えるようにしてみました。これは、話者の設定で好みの音程などを発見した時に他のユーザ様へその設定を伝えやすくなるといいなぁというご要望にお答えしようとした時に、簡単に実装できるのは何かなぁと考え、この方法なら一応伝達しやすくはなるし、実装コストも低く抑えられるという事で「とりあえず」実装してみたものになります。
次に、設定 -> 携帯電話網であダウンロードしないようにする の ON/OFF 設定を追加しました。こちらはなんとなく入れておいたほうがいいのかなぁと思い続けてそのまま忘れていたものなのですが、ご意見ご要望でお寄せくださいました方が現れましたので、返信を書くついでに実装方法を確認したところ、簡単に実装する方法があったようでしたのでその方法で実装したものになります。ちょっと心残りなのは、設定 -> 小説の自動更新 が ON の時に不定期に行われるダウンロードのみを停止するのではなく、携帯電話網のみに接続している間はたとえユーザ様自らがダウンロードを試みようとした場合でも、ダウンロードに失敗するような方式(つまり、いかなる場合でも携帯電話網のみではダウンロードできないようになる ON/OFF 設定)になっているという所でしょうか。これについては将来的に小説の自動更新時のみに ON/OFF の効果を適用するように変更するかもしれません(もしその動作が嫌だという方がおられましたら先にご意見ご要望フォーム等からお知らせいただけますと幸いです)。

また、以前のリリースノートでもお知らせしました通り、「なろう検索」タブを削除する作業を進めております。この修正は ことせかい 内部で利用しているデータベースを新しいデータベースに移行する時と同時に行われる予定です。この、新しいデータベースを利用した ことせかい では色々とできることが増える予定ですが、iCloud を使っての端末間同期に関しての実装(Apple Watch対応の根幹部分にもなっています)で少々手こずっているなどの問題があり、すぐには適用できない状態です。とはいえ、できれば今年中にはリリースできるといいなぁという気持ちで作業しておりますので、恐らく今年中にはその「なろう検索」タブが使えなくなったバージョンにアップデートがかかるという理解をしておいていただけますようお願いいたします。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。
また、結果報告を精力的にして頂けているβテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。


# Version 1.1.56

Interface Change

- Added support for DarkMode
- Added a search button to the novel text scene
- Display slide bar value in Settings -> Quality of voice
- Added settings -> Do not download on mobile phone network ON/OFF setting

Bug fix

- Do not display the menu that appears above the reading position display during reading


# Version 1.1.57

インタフェースの変更
- 「設定」->「小説本文表示画面の設定」(旧「表示文字の設定」)に小説本文部分の表示部での色設定を追加
  (この設定と重複するため「設定」->「小説を読む時に背景を暗くする」は削除されました。同設定をONにされていた方はお手数をおかけしますが、再度上記の設定にて背景を暗くする設定をするようお願いいたします)

問題の修正
- バックアップファイルから復元時にアプリが終了する可能性があった問題を修正

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正では小説を読む画面の色設定を少し柔軟に指定できるようにしました。これは、Version 1.1.56 にてダークモードに対応した時に、ダークモードに設定されていると背景が暗くなってしまうので明るい色に設定できるようにならないか、というお問い合わせを受けた事から来ています。例によってアプリ全体での色指定をするのは大変でしたのでざっくりと小説を読む画面のみの対応としています。
また、この設定は以前の「設定」->「小説を読む時に背景を暗くする」の機能も含みますため、この設定項目を削除致しました。「設定」->「小説を読む時に背景を暗くする」をONにされている方にはお手数をおかけして申し訳ありませんが、「設定」->「小説本文表示画面の設定」->「色設定」にて背景を暗くするような設定をして頂けますようお願いいたします。

また、以前のリリースノートでもお知らせしました通り、「なろう検索」タブを削除する作業を進めております。この修正は ことせかい 内部で利用しているデータベースを新しいデータベースに移行する時と同時に行われる予定です。この、新しいデータベースを利用した ことせかい では色々とできることが増える予定ですが、iCloud を使っての端末間同期に関しての実装(Apple Watch対応の根幹部分にもなっています)で少々手こずっているなどの問題があり、すぐには適用できない状態です。とはいえ、できれば今年中にはリリースできるといいなぁという気持ちで作業しておりますので、恐らく今年中にはその「なろう検索」タブが使えなくなったバージョンにアップデートがかかるという理解をしておいていただけますようお願いいたします。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。
また、結果報告を精力的にして頂けているβテスターの方々には様々な不都合の発見や詳しい状況の報告など、とても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.57

Interface change
- Add color settings at Settings -> Fiction text display settings.

Bug fix
- Fixed an issue where the app could quit when restoring from a backup file.


# Version 1.1.58

インタフェースの変更

- 設定 -> 小説を削除する時に確認する の設定項目を追加
- 設定 -> お知らせ で出てくるダイアログに「過去のお知らせを確認する」ボタンを追加
- DynamicType 対応部分を増やしました

問題の修正

- VoiceOver環境下において、本棚の右上にある「順番」などで出てくるピッカーダイアログが選択できなくなっていた問題を修正
- Web取込タブ内のブックマークで削除できない項目が発生し得た問題を解消

1.1.59

VoiceOver環境下での問題は全く気づいておりませんでした。開発者はVoiceOver環境下では生活しておりませんので、VoiceOver環境下での問題はほぼ全く気づいていないとお考え頂ければ幸いです。
といいますか、VoiceOver環境下の問題もそうなのですが、開発者は一人の人間ですし ことせかい の開発やデバッグにかけられる時間も限られておりますので、今現在存在する問題のほとんどを把握していない事が考えられます。そのため、「この問題全然直らないな、なんで直さないんだろう」というような事などありましたらサポートサイト下部にありますご意見ご要望フォームか、アプリ内の「設定」->「開発者に問い合わせる」からお問い合わせいただけましたら幸いです。(なお、サポートサイト下部にありますQ&Aで言及している問題や、Github側のissuesに登録されている問題については気づいているのですが、それらは何らかの理由で対応できていない問題となりますのでお時間がありましたら先にそれらをご確認の上、お問い合わせいただけますと助かります)。

次に、小説を削除する時に確認ダイアログを出すか否かの設定を追加しました。こちらは操作ミスで小説を削除されてしまった方から「なんとかなりませんか」というお問い合わせを受けたため、とりあえずの所という事で確認ダイアログを出せるようなオプションを追加したものになります。こちらは標準ではOFFになっております(今までと同じ動作が標準の動作になります)ので、操作ミスで小説を削除してしまう事を回避されたい方は設定タブからONにしてご利用下さい。

他に、設定 -> お知らせ で出てくるダイアログから、過去のお知らせを参照できるようにしました。こちらは『「設定」->「iOS 12 で読み上げ中の読み上げ位置表示がおかしくなる場合への暫定的対応を適用する」がONになっている時に空白等を「アルファ」と発話するようになってしまった』というお問い合わせが来る問題に対応するためにお知らせ機能でアナウンスした事があるのですが、そろそろもう同様の問題に悩まされている方も少なくなったようなのでとお知らせから外したところ、確かに少なくはなったのですがまだまだお問い合わせを送られてくる方がおられますので、過去のお知らせも確認できるようにすることで同様の問題を抱えている方がその場で気付ける導線を増やす事を目的としています。

次に、DynamicType(表示される文字の大きさを変更できる iOS のアクセシビリティ機能で、例えば iOS 13 では 設定アプリ -> アクセシビリティ -> 画面表示とテキストサイズ -> さらに大きな文字 で文字の大きさを指定できます)に対応して表示される文字の大きさが変わる部分を増やしました。老眼で文字が小さくて読めない、といった時にご利用下さい。なお、全ての表示文字についてDynamicTypeへ対応するのは正直な所大変なので、UI部品的に文字の大きさが変わっても表示が崩れにくい部分を中心に対応するようにしています。こちらは裏で作っている iCloud や AppleWatch への対応の枝側ではもう少し真面目に対応しているのですが、そちらも十分ではない状態ですので、DynamicType対応を両方の枝で真面目に対応するとなると時間がまた更に使われてしまって悲しいことになるため、リリース用の枝ではあまり頑張ってDynamicTypeへの対応はしない方向にしています。

また、以前のリリースノートでもお知らせしました通り、「なろう検索」タブを削除する作業を進めております。この修正は ことせかい 内部で利用しているデータベースを新しいデータベースに移行する時と同時に行われる予定です。この、新しいデータベースを利用した ことせかい では色々とできることが増える予定ですが、iCloud を使っての端末間同期に関しての実装(Apple Watch対応の根幹部分にもなっています)で少々手こずっているなどの問題があり、すぐには適用できない状態です。とはいえ、できれば今年中にはリリースできるといいなぁという気持ちで作業しておりますので、恐らく今年中にはその「なろう検索」タブが使えなくなったバージョンにアップデートがかかるという理解をしておいていただけますようお願いいたします。……と、アナウンスしていたのですが、どうやら今年中のリリースは無理そうです。有言実行できず申し訳ありません。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。
また、結果報告を精力的にして頂けているβテスターの方々には様々な不都合の発見や詳しい状況の報告など、いつもとても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。

# Version 1.1.58

Interface change

- add Settings -> "Confirm when deleting a novel"
- add "Check past notifications" button on Settings -> Information dialog
- Enhanced DynamicType support.

Bug fix

- Fixed an issue where the picker dialog that appeared in the "Order" etc. at the top right of the bookshelf could not be selected under VoiceOver.
- Resolved an issue that could cause items that could not be deleted with bookmarks in the Web Import tab.

# Version 1.1.59

インタフェースの変更

- 設定 -> バックアップ用データの生成 にて、生成されたデータについて「ファイルとしてシェア」が選択できるように

評価やレビュー、ありがとうございます。特にサポートサイト側のご意見ご要望フォームやアプリ内の不都合報告フォームからの詳細なバグ報告には本当に助けられています。アプリのレビュー欄でのお褒めの言葉もとても嬉しいです。これからも宜しくお願い致します。

今回の修正では、バックアップデータを生成した時に、ファイルとしてシェアする事を選択できるようにしました。これで iOS 11 辺りから使えるようになったファイルアプリを使うなどしてファイルとして扱うようにできるようになります。バックアップデータの中身を解析したいであるとかAirDropでWiFiを使わずに端末間データ共有をしたいであるとかいった用途にご利用下さい(iCloudでの同期については今後のアップデートをお待ち下さい。手元の開発版では動いてはいるんですよ。色々問題が残っているのでまだまだリリースできそうにはないのですけれども)
それで、このファイルでのシェア機能なのですが、案外簡単に実装できたのですね。NSDocument class に対応した物(ファイルのプレビューとかができるようにしないと駄目そうで実装コストがかなり高い物)にしないと駄目なんだと思っていたのですが、単純に UIActivityViewController にファイルのURLを渡してあげれば後はよろしくやってくれるみたいだったので、サッと実装してみました。
で、これを書いているのが12月20日の午前2時頃なのですけれど、Appleさんの審査ってだいたい2日位かかって、しかも、Appleさんの審査は12月23日から12月27日まで休暇に入っちゃうらしいのです。という事で、この修正がクリスマス前後にリリースできたとしたらAppleの審査の人にありがとうというお礼の念とかの感謝の気持を送っておいてあげて下さいネ！( ﾟ∀ﾟ)b

また、以前のリリースノートでもお知らせしました通り、「なろう検索」タブを削除する作業を進めております。この修正は ことせかい 内部で利用しているデータベースを新しいデータベースに移行する時と同時に行われる予定です。この、新しいデータベースを利用した ことせかい では色々とできることが増える予定ですが、iCloud を使っての端末間同期に関しての実装(Apple Watch対応の根幹部分にもなっています)で少々手こずっているなどの問題があり、すぐには適用できない状態です。とはいえ、できれば今年中にはリリースできるといいなぁという気持ちで作業しておりますので、恐らく今年中にはその「なろう検索」タブが使えなくなったバージョンにアップデートがかかるという理解をしておいていただけますようお願いいたします。……と、アナウンスしていたのですが、どうやら今年中のリリースは無理そうです。有言実行できず申し訳ありません。

さて、ここ何回かのアップデート時に告知しております通り、現在 ことせかい ではβテスターの募集を行っています。βテスターの募集に関する詳しい事は、サポートサイト下部のリンクにあります「ことせかい βテスター募集要項」を参照してください。
また、結果報告を精力的にして頂けているβテスターの方々には様々な不都合の発見や詳しい状況の報告など、いつもとても助けられています。ありがとうございます。お手数をおかけしますが、これからもお手伝いいただければ幸いです。

それでは、これからも ことせかい をよろしくお願いいたします。



# Version 1.1.59

Interface change

- Changed so that \"Share as file\" can be selected in Settings -> \"Create backup data\".

TODO:
- HTTP GET 周りをイベント駆動型に書き直す
- Google スプレッドシートで読み替え辞書を扱えるような何かを考える

----
TestFlight テスト情報

ベータ版 App の説明

インタフェースの変更

- 「再ダウンロード用データの生成」で保存される設定項目を増加

テストでは上記の変更点以外にも、既存の機能で動作しなくなったものなども確認して、不都合の有無を「不都合がなかった場合でも」報告してください。

----
in Japaneze.

今回のアップデートでは、年齢制限指定の「無制限のWebアクセス」を外すことを目的としたアップデートを行いました。
修正した事を以下に挙げます。

- "Web import"タブのURLバーへのURLや検索文字列の入力をできなくした。
- "Web import"タブのホームページ(ブックマークリスト)の標準値に設定してある Google へのリンクを削除した。

以上の修正により、"Web import"タブからはURLの入力やGoogle検索などができなくなります。そのため、初期値として保存されているサイトのみの閲覧ができるようになると考えています。
私達はこれによって、「無制限のWebアクセス」とは言えない状態になると考えております。
以上の修正をしましたが、これでは「無制限のWebアクセス」を外すことができないのであれば何が問題なのかを教えてください。
以上よろしくお願いします。

----
in Japanese.

今回のアップデートでは、ファイル拡張子が .novelspeaker-backup-json となっているファイルについて、アプリとの関連付けを行いました。
この機能はダウンロードされた小説等のバックアップ用途が目的です。
このファイルはアプリのSettingsPageにおいて"Create re-download URL"を用いて生成されます。
ユーザは生成された .novelspeaker-backup-json ファイルをアプリに読み込ませる事で、バックアップされた小説をもう一度ダウンロードし直す事ができるようになります。

.novelspeaker-backup-json ファイルの中身は JSON 形式となっており、おおよそ以下のような形式です。

{
"data_version" : "1.0.0",
"word_replacement_dictionary": {
"from word": "to word", ...
},
"bookshelf": [
{
"type": "url" or "ncode" or "user",
"ncode": ..., "title": ..., "id": ..., ...
]
}

上記の .novelskeaker-backup-json の中で、暗号化を使用してデータを保存する箇所が追加されました。
そのため、アプリのレビュー提出の際に暗号化機能の利用を「はい」にしました。
この暗号化機能はOS側で用意しているsha256(CC_SHA256()関数)を利用しています。

expedited app review に出した時の文言
---begin---
なろう検索のタブで、検索用文字列を入力できなくなっていた問題を修正しています。
この部分が入力できないと、検索で好みの小説を探すことができないため、あまり小説が選べないアプリになってしまっています。

問題の再現手順：

1. なろう検索 タブを開く
2. 一番上の「検索文字列」のテキストボックスを選択
3. 文字を入力する

3. のステップで、旧バージョンでは文字が入力できませんでした。

In English

In Search tab, Search string is now can editable.


The reproduction procedure of the problem:

1. Open the search tab
2. Choose the text box of a top "search string"
3. Input a letter

In 3. steppe, It was not able to input a letter in the old version.
----end----

# メモ

## ナビゲーションバー(上に出てくる「戻る」ボタンとかタイトルとかが表示される領域)に埋まる問題を解消するには、
インタフェースビルダの Adjust Scroll View Insets っていうチェックボックスを off にするといいっぽい。(理由理解してない)
http://qiita.com/yimajo/items/7c7372e284e13827c989

## iCloud で同期するには
CoreData を使う時の初期化に
NSPersistentStoreUbiquitousContentNameKey と NSPersistentStoreUbiquitousContentURLKey
というのを使うらしい？

Key-Value store とか Document Storage ってのでもできるっぽい。
http://blog.gentlesoft.net/article/56456255.html


http://d.hatena.ne.jp/glass-_-onion/20120728/1343471940

284話 たいがとの接触
