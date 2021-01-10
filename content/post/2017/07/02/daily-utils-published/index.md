---
title: "Daily utils published"
author: "makotow"
date: 2017-07-02T15:43:25.188Z
lastmod: 2020-01-05T03:11:16+09:00

description: ""

subtitle: "日常的に行う処理を定形化したスクリプトリポジトリ"
slug: 
tags:
 - Tech
 - Shell
 - Tools

categories:
-
archives: ["2017/07"]
aliases:
    - "/daily-utils-published-a4bb22af01d0"
---

## 日常的に行う処理を定形化したスクリプトリポジトリ

## 目的・背景

似たようなスクリプトを都度つくっていたので今回意を決してリポジトリに集めることとした。

今のところ差し障りのないスクリプトだけを登録している、このほかにもスニペット的なものがたくさんあるので同じリポジトリか別に作ろうと考えている。

## いま登録されているスクリプトたち

## tmux-ssh

その名の通り、tmux を複数のPaneを作成しコマンドラインで指定したホストにログインする機能、秘密鍵の指定、ログインユーザの指定が可能。

ログイン時点ですべてのホストへ同じコマンドを送れるようにしている。

[makotow/dailyutils](https://github.com/makotow/dailyutils/tree/master/tmux-ssh)


超シンプルなスクリプトと考えて使う。もしかするとここから進化するかもしれない。

作っては見たものの、より高機能なものが存在していた

[greymd/tmux-xpanes](https://github.com/greymd/tmux-xpanes)


## homebrew manager

brewm

homebrew を使う際の便利コマンド。

brew, brew caskどちらにも対応。

[makotow/dailyutils](https://github.com/makotow/dailyutils/tree/master/brewmanager)


`brewm updateall `とすると brew update, upgrade, clean up を実施する一括実施の機能。

ほとんどこれしか使わない。

## gosetup

その名の通り golang のディレクトリ構成を作ってくれるシンプルなモノ。

ディレクトリ作成時に、direnvの設定ファイルも同時に作成する

[makotow/dailyutils](https://github.com/makotow/dailyutils/tree/master/gosetup)


## readmegen

README.md を作成する。

ある程度のテンプレート、個人用途に特化しているもの。

以下のURLのREADME.md のようなテンプレートを生成する。

[makotow/dailyutils](https://github.com/makotow/dailyutils/tree/master/readmegen)
