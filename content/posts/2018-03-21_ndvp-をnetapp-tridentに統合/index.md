---
title: "nDVP をNetApp Tridentに統合"
author: "makotow"
date: 2018-03-21T17:05:24.991Z
lastmod: 2020-01-04T01:43:03+09:00

description: ""

subtitle: "コンテナ関連のソリューションを１つに。"
tags:
 - Kubernetes
 - Trident
 - Netapp
 - Storage
 - Tech

image: "/posts/2018-03-21_ndvp-をnetapp-tridentに統合/images/1.jpeg" 
images:
 - "/posts/2018-03-21_ndvp-をnetapp-tridentに統合/images/1.jpeg"


aliases:
    - "/ndvp-has-merged-with-trident-492d26a9e9a8"

---

#### コンテナ関連のソリューションを１つに。


![image](/posts/2018-03-21_ndvp-をnetapp-tridentに統合/images/1.jpeg#layoutTextWidth)

TridentにnDVPが統合



#### Trident 18.01 リリース

まずは2018年１月に Trident 18.01 (kuberentes 連携ソリューション)がリリースされ、そのリリースアナウンスの中にnDVPを統合というノートがありました。

18.01 は Cloning 機能のサポートなどが含まれており様々な新機能が増えたので見落としてました。

#### 背景

歴史的な背景から最初に コンテナデータ永続化のパイオニアであるFlocker用のインテグレーションとして開発され、その後Dockerのプラグイン機構が整理されDocker用のプラグインとしてnDVP が作成されました。

そしていまではkubernetesが市場でもつ意味が非常に大きくなり、kubernetes用のdynamic storage provisionerであるTridentがリリースされました。

そして今回、動的ストレージプロビジョニングをTrident１つにまとめたという形になりました。  
 Tridentで出来ることはアプリケーションからストレージが要求されたら動的にプロビジョニングし、コンテナにマウントするまでを行ってくれます。

#### Container Storage Interface(CSI)との関係

CSIとはストレージベンダーが複数のコンテナオーケストレータそれぞれに対応しなくていいように業界標準となるインターフェースです。たとえば、Kubernetes用にpluginを作成したら他のオーケストレータ(Docker, Mesos, CloudFoundry) でも使用可能となります。

NetAppは、このような標準化においてコミュニティへノウハウの提供やコミュニティ活動を強力に支援しています。

#### ドキュメント

こちらに最新のドキュメントが公開されております。

[Trident Storage Orchestrator for Containers](https://netapp-trident.readthedocs.io/en/stable-v18.01/)

次回配信ではnDVPをTridentに置き換えて使ってみた結果をお届けしたいと思います。

#### まとめ

nDVPがtridenに統合されてNetAppのコンテナ関連のソリューションはTridentに一本化しました。
