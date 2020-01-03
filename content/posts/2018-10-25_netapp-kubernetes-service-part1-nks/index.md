---
title: "NetApp Kubernetes Service Part1 NKS"
author: "makotow"
date: 2018-10-25T11:21:18.479Z
lastmod: 2020-01-04T01:43:15+09:00

description: ""

subtitle: "Getting started NKS"
tags:
 - K8s
 - Tech
 - Container

image: "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/1.png" 
images:
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/1.png"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/2.jpeg"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/3.jpeg"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/4.png"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/5.jpeg"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/6.jpeg"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/7.jpeg"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/8.jpeg"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/9.jpeg"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/10.jpeg"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/11.jpeg"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/12.jpeg"
 - "/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/13.jpeg"


aliases:
    - "/netapp-kubernetes-service-part1-nks-179211138638"

---

#### Getting started NKS




![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/1.png#layoutTextWidth)



NetApp Kubernetes Service (NKS)の使い所を見ながら、ポイントとなる機能をみていくシリーズです。

第１回目は基本編として簡単な使い方から存在する機能を見ていきたいと思います。   
 これから何回続くかは不明ですが現時点では以下のコンテンツも考えています。

*   自作Helm Chartを登録する
*   Heptio Arkを使ってバックアップ・リストア
*   Federationを試す！

#### What is NetApp Kubernetes Service (NKS)

一言で説明すると、各種クラウドプロバイダーに Kubernetesをデプロし、デプロイ後の管理までをしてくれる **SaaS** です。

バックエンドでは通常のVM(AWSであればEC2)をデプロイし、kubernetesをインストールする方法と、各種クラウドプロバイダーが提供しているk8s serviceをデプロイします。

それだけではなく、事前にHelmチャートを指定しておけばデプロイ時に自動でインストールしてくれます。

その他にもマネージドでバックアップを取得することやクラスタのフェデレーションといったことをクリックだけで実現できます。

今回は基本的なオペレーションを見ていきます。

#### サービスポータル

以下のURLからNKSを使える。

*   [https://cloud.netapp.com](https://cloud.netapp.com)

![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/2.jpeg#layoutTextWidth)

クラウドセントラル、サービスのダッシュボード



サインアップして、サービス一覧へ。


![Topページ](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/3.jpeg#layoutTextWidth)

ユースケース一覧、右の矢印をクリック



「Go to Cloud Data Services」をクリックして


![NKS](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/4.png#layoutTextWidth)

サービス一覧



#### 基本オペレーション

約３クリックでkubernetesクラスをある程度のHelm chart入りでデプロイができます。

#### 各種アカウント登録

もちろんデプロイをするには各種クラウドプロバイダのクレデンシャル登録が必要になります。

最初になにも登録していないと登録を促す画面がでるので適宜登録します。

#### デプロイメントの流れ

#### サービス選択


![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/5.jpeg#layoutTextWidth)

デプロイするプロバイダーを選択



ここではAWSを選択します。  
 その後、以下の画面に遷移して、デプロイするマスターノードの数、ワーカーノードの数、ディスクサイズやデプロイするVPCを選択する画面になります。

10/25時点でGPUサービスが追加されていました。


![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/6.jpeg#layoutTextWidth)

リソースの設定をする画面



デプロイ先などを選んだら画面したの「Submit」で次の画面へ。

#### 必要な要素を選択(Solutions)

ここまで来るとデプロイまでもうすぐです。  
 ここではクラスタ名、デプロイするk8sのバージョン、RBACやダッシュボードをインストールするか、Pod/Service ネットワークのIP指定。

デプロイするk8sを形成するOSなどを選択します。


![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/7.jpeg#layoutTextWidth)

ソフトウェアの導入・バーションの設定



「ADD SOLUTIONS」というボタンをクリックすると、  
 デプロイ時に導入するアプリケーションを選択できます。

３つ種類があって事前に導入する予定のHelmChartを選択できます。

*   NetApp Container Engine Solution
*   Trusted Chart
*   My Charts

![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/8.jpeg#layoutTextWidth)

登録されているHelmチャート一覧



デプロイした時点で Prometheusが稼働していたり、Istioが稼働しているといったものが作れます。

また、 My Chartについては自分たちで準備しているHelm repositoryを登録することができます。

ちなみに Prometheus を追加すると、依存関係のあるHAPROXYも自動で追加してくれます。


![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/9.jpeg#layoutTextWidth)

依存関係も見てくれる。



これで画面下の「Submit」をクリックするとデプロイが始まります。  
 デプロイが完了するとユーザ作成時に登録したメールアドレスにクラスタ作成完了のメールが届きます。

出来上がったクラスタは一覧でみることができます。


![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/10.jpeg#layoutTextWidth)

クラスタ一覧



#### デプロイ後のクラスタに対する操作

出来上がったクラスタのクラスタ名をクリックするとクラスタの詳細をみることができます。


![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/11.jpeg#layoutTextWidth)

クラスタの構成



この画面からマスターノードの追加、ワーカーノードの追加、Solutionsの追加ができます。

その他にも現在稼働中のDeploymentを確認することができます。

構成情報のバックアップにも対応しており、同一画面で Heptio Ark の有効化、設定を行うことができます。

直感的になにをするかわかりますが、一応説明すると、Heptio 自体がk8sの構成情報をバックアップしてくれます。

この画面では以下のような入力項目を入れると定期的にk8sのバックアップ情報を取得してくれます。

*   バックアップしたデータをどこに保存するか？
*   どのリージョンに保存するか？
*   頻度はどのくらいか？
*   使うクレデンシャルは？

![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/12.jpeg#layoutTextWidth)

heptio Arkの設定



リストアもこの画面から実施することができます。


![image](/posts/2018-10-25_netapp-kubernetes-service-part1-nks/images/13.jpeg#layoutTextWidth)



リストアボタンをクリックすると現状取得しているバックアップの一覧がでてきてここから戻すことができます。

#### まとめ

今回はNKS自体の説明と具体的なデプロイまでのオペレーション、デプロイ後になにができるかを書いてみました。

これからは上記の画面に出てきている 「Federation」、「Istio Mesh」や「Heptio Ark」を使ってみた系をやってみたいと思います。
