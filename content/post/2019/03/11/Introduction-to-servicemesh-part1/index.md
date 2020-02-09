---
title: "ゼロから始めるサービスメッシュ入門 Part1"
author: "makotow"
date: 2019-03-11T12:16:09.548Z
lastmod: 2020-01-05T03:12:11+09:00

description: "Istioの学習記録"

subtitle: "Istioの概要を学んでみた"
slug: 
tags:
 - Istio
 - Service Mesh
 - Tech
 - Kubernetes

series:
-
categories:
-
thumbnailImagePosition: top
thumbnailImage: "/images/20190311/1.png" 
aliases:
    - "/learning-istio-from-zero-part1-23792f11ddb3"

---

#### Istioの概要を学んでみた

### 概要

Istioの学習記録、今回は本家のマニュアルに書いてあることの理解を深める回であり、  
人に伝えるためにはどのように考えて伝えればよいかを洗い出す目的で記述する記事です。
<!--more-->
<!--toc-->

### 今回の範囲・目標

主に以下のことを理解するのが目標です。

*   Istioとは？
*   なぜ必要か？

### What is Istio?

まずは本家を読む。

[What is Istio?](https://istio.io/docs/concepts/what-is-istio/)

Microserviceが前提となっています。

Microserviceの説明をしてから、Microserviceのなにが課題になるのかを理解してもらい、ServiceMeshの概念を導入する必要があります。

と思ったら次の文章に同じことが書いてあった。

超概要として翻訳したものが次のセクションの内容です。

### Service Meshとは?

Istioはモノリシックなアーキテクチャから分散したマイクロサービスへの転換期に開発者、運用者が直面する課題を解決できます。IstioのServiceMeshを詳しく調べることでその方法を知ることができます。

Service Meshという用語はマイクロサービスのネットワークのことを指し、アプリケーションや相互作用はServiceMeshを介して構成されます。

Service Meshはサイズ、複雑度が上がっていき、管理と理解が難しくなっていきます。  
Service Meshの要件にはディスカバリ、ロードバランス、障害回復、メトリクス、監視が含まれます。

ServiceMeshにはA/Bテスト、カナリアリリース、レートリミット、アクセスコントロール、e2e 認証（←マイクロサービス間の認証のことかな？）などのより複雑な運用要件もあります。

Istioは、サービスメッシュ全体の動作に関するインサイトと運用管理を提供し、マイクロサービスアプリケーションの多様な要件を満たすための完全なソリューションを提供します。

### なぜIstioをつかうのか？

Istioはデプロイ済みのService(k8s のリソース）にロードバランス可能なネットワーク、サービス間の認証、監視、などをサービスのコード書き換えなしに簡単に作成できます。sidecar proxyをデプロイすることでマイクロサービス間のすべてのネットワーク通信をinterceptすることができます。そして、コントロールプレーンの機能を使って構成とIstioの管理ができます。

コントロールプレーンの機能は以下の通り。（※翻訳している時点でわかっていないところもあり。）

*   HTTP, gRPC, WebSocket, TCPの通信を自動ロードバランス
*   リッチなルーティングルール、リトライ、フェイルオーバー、fault injection を使ったきめ細やかなトラフィックの振る舞いコントロール
*   プラグイン可能なレイヤとアクセスコントロール、レートリミット、クォータ
*   ingress/egressを含んだクラスタ内のすべてのメトリック、ログ、トレーストラフィックを取得
*   強力な認可と認証に基づいた安全なサービス間通信

### 主な機能

書いてあるままなのでリンク貼り付け。

[What is Istio?](https://istio.io/docs/concepts/what-is-istio/#traffic-management)

### Istio のアーキテクチャ

**Data Plane**と**Control Plane**で構成されています。

*   **Data Plane**: インテリジェントプロキシ(Envoy)の集合体、サイドカーとしてデプロイされる
*   Envoy Proxyはすべてのマイクロサービス間ネットワークトラフィックを仲介、管理し、Mixerと連携。
Mixerはポリシー、テレメトリのハブとなる。
*   **Control Plane**: Proxyの管理と構成、ルートトラフィック。
追加でMixerの構成とポリシー、テレメトリ収集を強制させる



![image](/posts/2019/03/11/ゼロから始めるサービスメッシュ入門-part1/images/1.png#layoutFillWidth)

Istioアーキテクチャ

*   [https://istio.io/docs/concepts/what-is-istio/arch.svg](https://istio.io/docs/concepts/what-is-istio/arch.svg)

他にもIstioを構成するコンポーネントは以下のURLに記載がります。ここではすべてを説明せずにリファレンスをします。

[What is Istio?](https://istio.io/docs/concepts/what-is-istio/#architecture)


1.  **Envoy:** ハイパフォーマンスプロキシ、サービスメッシュないのすべてのインバウンド、アウトバウンド通信を仲介します。IstioはEnvoyの機能を応用している。サイドカーコンテナとしてk8sのPodとして起動します。Mixerと連携してポリシーを適応したり、モニタリングを行います。
2.  **Mixer:** プラットフォーム非依存なコンポーネントです。アクセスコントロール、ポリシーの使用をクラスタ感で実現します。Envoyや他のサービスからテレメトリデータを収集もします。
3.  **Pilot:** Envoyサイドカーのためのサービスディスカバリー、インテリジェントルーティングのためのトラフィック管理（例えば、A/Bテスト、カナリアリリースなど）、回復性（タイムアウト、リトライ、サーキットブレーカー、など）を提供します。
4.  **Citadel:** サービス間とエンドユーザー認証を組み込み済みのクレデンシャル管理を用いて提供します。
5.  **Galley:** トップレベルのコンフィグのインジェスト、処理、配布をするIstioのコンポーネント

### **Istioの目指すところ**

[https://istio.io/docs/concepts/what-is-istio/#design-goals](https://istio.io/docs/concepts/what-is-istio/#design-goals)

上記URL参照。

### まとめ

今回は概要についてまとめて見ました。

伝えるときにどのように伝えるかやはりこの状態からだと前提となる知識が多そうで難しいという印象となりました。

次回以降実際にデプロイ、実際の動作確認をしていきます。
