---
title: "最近つかったツール: nativefier"
author: "makotow"
date: 2018-06-12T14:05:45.743Z
lastmod: 2020-01-05T03:11:55+09:00

description: "nativefierを使ったアプリ化を試してみました。"

subtitle: "ウェブアプリ、ネイティブアプリ化への道筋"
slug: 
tags:
 - Tech
 - Mac
 - Nodejs
 - Productivity

series:
-
categories:
-



aliases:
    - "/%E6%9C%80%E8%BF%91%E3%81%A4%E3%81%8B%E3%81%A3%E3%81%9F%E3%83%84%E3%83%BC%E3%83%AB-nativefier-5d7b582cddca"

---

#### ウェブアプリ、ネイティブアプリ化への道筋

#### 動機

[Asana](https://app.asana.com/) を使い初めていい感じだったのでMac用のアプリがほしいと思って調べたところ、たくさんの要望があるがまだ実現に至っていないことがわかった。  
 コミュニティのスレッドのなかで[nativefier](https://github.com/jiahaog/nativefier)を使ってアプリ化したよという意見があったので早速試してみた。

#### nativefier?

要するにウェブサービスをネイティブアプリ化するもの。

仕組みとしては、ElectronでラップしてMacで動作するようAppとしてパッケージするもの。  
 任意のウェブページがアプリ化できる。

NodeJSで作成されているので、以下のコマンドで一発導入。
``npm install nativefier -g``

アプリ化は、引数にURLを指定するだけ。
``nativefier  &#34;http://medium.com&#34;``

#### nativefierを使ってみたサービス

よくよく考えてみると、よく使うウェブサービスでネイティブアプリが欲しいものは以下の2つだった。

*   Medium
*   Asana

#### 問題発生

Googleアカウントで認証している場合、別ウィンドウ（ブラウザ）が開いてしまい、nativefier で作成したアプリケーションないでは開けなかった。

#### 解決方法

やはり皆様ハマるようで。

具体的な対策としては、nativefierないで開くURLを指定して、アプリ化するという方法。

[Issues with OAuth authentication (Asana, 22tracks, Sunrise, ...) · Issue #164 · jiahaog/nativefier](https://github.com/jiahaog/nativefier/issues/164)


Asanaはこちら
``nativefier --name &#34;Asana&#34; --internal-urls &#34;.*(harvestapp|google|getharvest)\.com.*&#34; [https://app.asana.com/](https://app.asana.com/)``

Mediumはこちら
``nativefier --name &#34;Medium&#34; --internal-urls &#34;.*(medium|google)\.com.*&#34; [https://medium.com](https://medium.com)``
