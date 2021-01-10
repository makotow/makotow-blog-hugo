---
title: "NetApp Kubernetes Service Part2 Kubernetes Backup/Restore with Heptio Ark"
author: "makotow"
date: 2018-12-23T04:51:07.806Z
lastmod: 2020-01-05T03:12:04+09:00

description: "Kubernetes backup and restore."

subtitle: "Heptio Ark を使ったバックアップ・リストア"
slug: 
tags:
 - Kubernetes
 - Netapp
 - Tech
 - Heptioark
categories:
-
archives: ["2018/12"]

images:
 - "./images/1.jpeg"
 - "./images/2.png"
 - "./images/3.jpeg"
 - "./images/4.png"
 - "./images/5.jpeg"
 - "./images/6.png"
 - "./images/7.png"
 - "./images/8.png"
 - "./images/9.png"
 - "./images/10.png"
 - "./images/11.png"
 - "./images/12.png"
 - "./images/13.png"
 - "./images/14.png"


aliases:
    - "/netapp-kubernetes-service-part2-kubernetes-backup-restore-with-heptio-ark-a0b5e24597c1"

---

## Heptio Ark を使ったバックアップ・リストア

NetApp Kubernetes Service (NKS)の使い所を見ながら、ポイントとなる機能をみていくシリーズです。

第2回目はHeptio Arkを使ったバックアップをやってみます。

Heptio が VMWareに買収発表されたのが記憶に新しいですが、Kubernetesのバックアップツールとしてはデファクトのツールです。

これから何回続くかは不明ですが現時点では以下のコンテンツも考えています。

*   [Part1 NKSを使う](https://medium.com/makotows-blog/netapp-kubernetes-service-part1-nks-179211138638)
*   **今回 Part2 Heptio Arkを使ってバックアップ・リストア**
*   自作Helm Chartを登録する
*   Federationを試す！
*   ServiceMeshを試す！

Part1は実施した前提(NKSでk8sクラスタデプロイ済み)として、以下すすめます。

#### バックアップ設定の基本オペレーション

NKSの画面から Heptio Ark をクリックすると以下の画面になります。


![Heptio Ark](./images/1.jpeg#layoutTextWidth)

Heptio ark 設定画面



「Enable Kubernetes State Backup」をクリックしてバックアップを有効にします。


![image](./images/2.png#layoutTextWidth)

バックアップオン



バックアップ取得先を「AWS S3」として、リージョンを選択します。  
その後、Frequencyでバックアップする頻度を選択します。

S3バケットは自動で作成するため登録しているクレデンシャルがS3バケットの作成権限を持っていれば問題ありません。

その後画面下の「Save」ボタンを押すと以下のメッセージがポップアップ表示されます。


![image](./images/3.jpeg#layoutTextWidth)



画面左のイベントログから今行った実行ログが確認できます。


![image](./images/4.png#layoutTextWidth)



![image](./images/5.jpeg#layoutTextWidth)

ark がインストールされる



#### AWS S3を見てみる

Ark 設定後にAWS S3のコンソールからバケットの確認をします。


![image](./images/6.png#layoutTextWidth)



バケット名は ark+[クラスタの識別子] という形になっています。

更に中を見ていくと、初回起動のタイミングですでに１つバックアップが取得されています。


![image](./images/7.png#layoutTextWidth)



バケットの内容は以下の３ファイルです。


![image](./images/8.png#layoutTextWidth)



*   ark-backup.json: Ark自体の構成情報
*   default-schedule-20181222160057-logs.gz: バックアップのログ
*   default-schedule-20181222160057.gz: k8sクラスタの構成情報の塊

ここまでで構成情報がバックアップされていることが確認できました。  
 時間が立てば設定した単位でバックアップが取得されていきます。

現在のところリテンションポリシー的なものは設定できないのでどれくらい保管しておくかは別途確認になります。

#### リストアを実施する

現在クラスタにデプロイしているものは以下の通りです。


![image](./images/9.png#layoutTextWidth)

クラスタにインストールされているソリューションの状況(NKSからデプロイしたもの）



Jenkinsを削除してからリストを試します。

以下はJenkinsを削除したところ。


![image](./images/10.png#layoutTextWidth)



リストアすることでJenkinsがもとに戻ることを確認します。

#### リストアオペレーション

Ark から「RESTORE]ボタンをクリック。


![image](./images/11.png#layoutTextWidth)

リストア時はリストアボタンをクリックするだけ



今までに取得されているバックアップ一覧が出てきます。  
 該当のバックアップを選択して、「RESTORE THIS BACKUP」をクリックして復元開始です。


![image](./images/12.png#layoutTextWidth)



Heptio Arkのアイコン横にあるインジケータが動き始めます。


![image](./images/13.png#layoutTextWidth)

復元中



上記Solutionリストには戻りませんでしたが、Deploymentとしては復元できました。ラベルにark-restoreが付与されます。


![image](./images/14.png#layoutTextWidth)



ただし、`service.type: LoadBalancer` で実施している場合は新たにロードバランサーが作成されていましたので、DNSでCNAMEをつけている場合は付け直しになります。

今回は復旧できるかというところを見たため手動で設定し直しましたが、運用を考えるとこのあたりも自動化を検討すべきポイントです。

#### やってみて気づいたこと

1.  UI自体がシンプルであるため、バックアップ取得したクラスタへしか復元ができませんでした。
 保管方法等をみてもHeptio Arkそのもののため、個別に ark クライアントを入れれば他のクラスタからもバックアップを参照し復元することができます。
2.  当たり前ですが、PVCのreclaimPolicyは障害が起きたところまでを考えて設定すべき。たまたま上げていたJenkinsを題材にしていましたがHelmから展開したタイミングでデフォルトのStorageClass、reclaimPolicy となっており一旦停止した際にデータがすべて消えました。（なので今回はDeploymentoが戻っただけの確認とします。PVCが残っていれば問題なく動く話なので。PVC残した状態は別の機会に再度チャレンジ）
3.  遠隔地で立ち上げるというタイミングがあるかわかりませんが結局データ転送しておき、PVC/PVとして認識させておく必要がある。現状どうやるか。

#### まとめ

今回はNKSで提供しているHeptio ark 連携の具体的なオペレーション、バックアップ、リストア方法について記事にしました。

Heptio Arkそのものを知っている方からすると細かい使い方ができないという印象を持つかもしれませんが、個人的にはポチポチやってここまでできればいいかなと言う感覚です。  
 これ以上に細かい操作はCLIで実施となるでしょう。
