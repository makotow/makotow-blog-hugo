---
title: "E-Series Grafana-Graphite Integration"
author: "makotow"
date: 2017-03-23T07:12:26.115Z
lastmod: 2020-01-04T01:42:01+09:00

description: ""

subtitle: "E-Series Grafana Graphite Integration でモニタリング"
tags:
 - Docker
 - Grafana
 - Graphite
 - E Series
 - Tech

image: "/posts/2017-03-23_eseries-grafanagraphite-integration/images/1.png" 
images:
 - "/posts/2017-03-23_eseries-grafanagraphite-integration/images/1.png"
 - "/posts/2017-03-23_eseries-grafanagraphite-integration/images/2.png"
 - "/posts/2017-03-23_eseries-grafanagraphite-integration/images/3.png"
 - "/posts/2017-03-23_eseries-grafanagraphite-integration/images/4.png"
 - "/posts/2017-03-23_eseries-grafanagraphite-integration/images/5.png"
 - "/posts/2017-03-23_eseries-grafanagraphite-integration/images/6.png"
 - "/posts/2017-03-23_eseries-grafanagraphite-integration/images/7.png"
 - "/posts/2017-03-23_eseries-grafanagraphite-integration/images/8.png"


aliases:
    - "/e-series-grafana-graphite-integration-112ece220b48"

---

#### [E-Series Grafana Graphite Integration](https://github.com/plz/E-Series-Graphite-Grafana) でモニタリング

*   [https://github.com/plz/E-Series-Graphite-Grafana](https://github.com/plz/E-Series-Graphite-Grafana)

今回 は ONTAP の Grafana 連携である harvest を参考に作成された E-Series-Graphite-Grafana の紹介、構築手順を紹介します。

E-Series 単体のパフォーマンスメトリクスを取得するツールだと一時的な性能情報しか取れず後に確認したい場合などに困ることがあります。E-Series-Graphite-Grafana を使用すれば、データは時系列DBの Graphiteに保存でき、可視化は Grafana を使用して直感的にわかりやすいGUIを提供します。

#### 完成形の画面


![image](/posts/2017-03-23_eseries-grafanagraphite-integration/images/1.png#layoutTextWidth)



#### 必要スペック(稼働確認したスペック）

今回紹介する環境を稼働させたスペック、サーバ構成を記載します。

今回は簡易的に性能情報を取得する目的であったため、1VMにすべてを詰め込んだ構成になっています。

*   CentOS 7 (server platformをインストール)
*   SELinux は disable
*   E-Series WebService Proxy 2.0
*   Grafana
*   Perl 5.18cpanモジュールは以下を導入しています。

*   LWP::UserAgent
*   MIME::Base64
*   JSON
*   Config::Tiny
*   Benchmark
*   Scalar::Util

#### 今回構築する環境

今回は簡易化のために Grafana/Graphite は Docker Hub で公開されている docker image を使用しました。選定したポイントとしては環境変数で様々な設定ができるようになっている Docker イメージを使用しています。

「E-Series Graphite Grafana」 は CentOS へインストールしています。

Perl 5.18 で稼働を確認しているため plenv を使用し、

必要な CPAN モジュールのインストールには cpanm を使用しています。

#### 使用するGrafana + Graphite docker image

以下の２つの Docker イメージを使用しました。

*   [Docker Image for Graphite &amp; Statsd](https://github.com/hopsoft/docker-graphite-statsd)
*   [Grafana XXL](https://github.com/monitoringartist/grafana-xxl)

データ永続化のため以下のフォルダを作成します。

*   /opt/graphite-grafana/grafana
*   /opt/graphite-grafana/graphite/configs
*   /opt/graphite-grafana/graphite/data
*   /opt/graphite/storage

#### Grafanaの起動
``docker run -d -p 3000:3000 -v /opt/graphite-grafana/grafana:/var/lib/grafana  -e &#34;GF_SERVER_ROOT_URL=http://10.128.221.213&#34; -e &#34;GF_SECURITY_ADMIN_PASSWORD=admin&#34; monitoringartist/grafana-xxl:latest``

#### Graphite の起動
``docker run -d --name graphite --restart=always -p 80:80 -p 2003-2004:2003-2004 -p 2023-2024:2023-2024 -p 8125:8125/udp -p 8126:8126 -v /opt/graphite-grafana/graphite/configs:/opt/graphite/conf -v /opt/graphite-grafana/graphite/data:/opt/graphite/storage -v /opt/graphite-grafana/graphite/statsd:/opt/statsd hopsoft/graphite-statsd``

**Docker volume を指定するときのホスト側のパスは絶対パスであることに注意してください**#### SANTricity Manager の設定

E-Series SANTricityから以下の２つの設定を行います。

admin のパスワード設定

「SetUp」 タブから administrator パスワードの変更




![image](/posts/2017-03-23_eseries-grafanagraphite-integration/images/2.png#layoutTextWidth)

Setup タブから Administratorのパスワード変更



「Performance」タブから 性能情報取得用のカウンタ起動


![image](/posts/2017-03-23_eseries-grafanagraphite-integration/images/3.png#layoutTextWidth)

SANTricity Managerの画面（性能情報）



![image](/posts/2017-03-23_eseries-grafanagraphite-integration/images/4.png#layoutTextWidth)

統計情報収集のモニタ起動

#### WebService Proxy (WSP) の設定

E-Series-Graphite-Grafana は性能情報を取得するため、 WebService Proxy を使用します。

WebService Proxy とは E-Series のプロビジョニング・構成情報取得をREST APIで可能にする API エンドポイントです。

*   WSP 自体のインストールはマニュアル参照
*   WSP の設定 (/opt/netapp/santricity_web_services_proxy/wsconfig.xml) の設定

以下に wsconfig.xml のサンプルを記載します。
`&lt;config version=”1&#34;&gt;``&lt;! — non-ssl port if not specified, no listener is made →  
 &lt;sslport clientauth=”request”&gt;8443&lt;/sslport&gt;  
 &lt;! — comma seperated list of protocols Possible values: SSLv3,TLSv1,TLSv1.1 →  
 &lt;exlude-protocols&gt;SSLv3&lt;/exlude-protocols&gt;``&lt;port&gt;8080&lt;/port&gt;  
 &lt;workingdir&gt;/opt/netapp/santricity_web_services_proxy/working&lt;/workingdir&gt;  
 &lt;datadir&gt;data&lt;/datadir&gt;  
 &lt;appkey&gt;webapi-2.0&lt;/appkey&gt;  
 &lt;enable-auto-update&gt;false&lt;/enable-auto-update&gt;``&lt;msgqueue-port&gt;61616&lt;/msgqueue-port&gt;  
 &lt;env-entries&gt;  
 &lt;! — Logger configuration. Use INFO (standard) or FINE (debugging). →  
 &lt;! — Both stats.poll keys must be set to collect analyzed stats. →  
 &lt;! — stats.poll.interval is expressed in seconds. -1 means disabled. 0 is no delay. →  
 &lt;! — stats.poll.save.history is expressed in days. 0 means disabled. →  
 &lt;env key=”trace.level”&gt;INFO&lt;/env&gt;  
 &lt;env key=”audit.level”&gt;INFO&lt;/env&gt;  
 &lt;env key=”system.level”&gt;INFO&lt;/env&gt;  
 &lt;env key=”webserver.level”&gt;INFO&lt;/env&gt;  
 &lt;env key=”enable-basic-auth”&gt;true&lt;/env&gt;  
 &lt;env key=”mel.events.cache.max”&gt;8192&lt;/env&gt;  
 &lt;env key=”autodiscover.ipv6.enable”&gt;false&lt;/env&gt;  
 &lt;env key=”autodiscover.ipv4.enable”&gt;true&lt;/env&gt;  
 &lt;env key=”stats.poll.interval”&gt;60&lt;/env&gt;  
 &lt;env key=”stats.poll.save.history”&gt;1&lt;/env&gt;  
 &lt;env key=”firmware.repository.path”&gt;firmware&lt;/env&gt;  
 &lt;/env-entries&gt;  
&lt;/config&gt;`

*   WSP は systemctl で起動、標準で自動実行で設定されています。

#### E-Series Grafana Graphite

GitHub からダウンロードしたモジュールはそのままは使用できないため3ファイル変更しました。

*   eseries-metrics-collector.pl の 起動シェルの変更
*   Systemctl に登録する際のパスの変更
*   plenv で入れたPerl のパスに変更 (本番運用時は要検討）

設定項目としては WSPの接続先アドレス、接続時の接続情報の設定、graphiteの接続ポートの変更( docker image のものと揃える）

一連のインストール方法は以下の通りです。
``$ cd /opt/  
$ mkdir netapp  
$ cd netapp/  
$ git clone [https://github.com/plz/E-Series-Graphite-Grafana.git](https://github.com/plz/E-Series-Graphite-Grafana.git)``

以下に変更したファイルのdiff を提示します。
``$ git diff  
diff --git a/graphite-collector/eseries-metrics-collector.pl b/graphite-collector/eseries-metrics-collector.pl  
index ab53561..ab39313 100755  
--- a/graphite-collector/eseries-metrics-collector.pl  
+++ b/graphite-collector/eseries-metrics-collector.pl  
@@ -1,4 +1,4 @@  
-#!/usr/bin/perl  
+#!/root/.plenv/shims/perl  

Copyright 2016 Pablo Luis Zorzoli  
@@ -28,7 +28,7 @@ use Benchmark;  
 use Sys::Syslog;  
 use Scalar::Util qw(looks_like_number);  

-my $DEBUG            = 0;  
+my $DEBUG            = 1;  # debug info  
 my $API_VER          = &#39;/devmgr/v2&#39;;  
 my $API_TIMEOUT      = 15;  
 my $PUSH_TO_GRAPHITE = 1;  
diff --git a/graphite-collector/proxy-config.conf b/graphite-collector/proxy-config.conf  
index aed59ed..52e7b86 100644  
--- a/graphite-collector/proxy-config.conf  
+++ b/graphite-collector/proxy-config.conf  
@@ -1,7 +1,7 @@  

Santricity Web Services Proxy hostname, FQDN, or IP  

-proxy = mywebservice.example.com  
+proxy = localhost  

Protocol (http|https)  
@@ -20,14 +20,14 @@ port = 8080  
User and password to connect with  

 user        = ro  
-password    = XXXXXXXXXXXXXXX  
+password    = ro  

Graphite Details  

 [graphite]  
 server      = localhost  
-port        = 3002  
+port        = 2003  
 proto       = tcp  
 root        = storage.eseries  
 timeout     = 5  
diff --git a/misc/eseries-metrics-collector.service b/misc/eseries-metrics-collector.service  
index a32455d..4e4ba3e 100644  
--- a/misc/eseries-metrics-collector.service  
+++ b/misc/eseries-metrics-collector.service  
@@ -11,7 +11,8 @@ StandardOutput=syslog  
 StandardError=syslog  
 SyslogIdentifier=eseries  
 SyslogLevel=notice  
-ExecStart=/bin/dash -c &#39;while true; do ./eseries-metrics-collector.pl -c proxy-config.conf ; sleep 60 ; done&#39;  
+#ExecStart=/bin/dash -c &#39;while true; do ./eseries-metrics-collector.pl -c proxy-config.conf ; sleep 60 ; done&#39;  
+ExecStart=/bin/bash -c &#39;while true; do ./graphite-collector/eseries-metrics-collector.pl -c ./graphite-collector/proxy-config.conf ; sleep 60 ; done&#39; # /bin/dash -&gt; /bin/bash へ変更、confファイルのパスを変更  
 Restart=on-failure  

man systemd.unit``

E-series-metrics-collector を systemctl でサービスに登録します。
``systemctl enable /opt/netapp/E-Series-Graphite-Grafana/eseries-metrics-collector.service  
systemctl start eseries-metrics-collector``

#### Grafana + Graphite の設定

ここまで設定ができたらGrafana から Graphite をデータソースとして登録します。

Graphite 起動時のパラメータで指定した URL を指定します。


![image](/posts/2017-03-23_eseries-grafanagraphite-integration/images/5.png#layoutTextWidth)

Grafana データソース登録画面



データソースを登録するとダッシュボード上で性能値を見ることができるようになります。

GrafanaにインポートするダッシュボードはGitHub上に公開されています。必要に応じてインポートしてください。

*   [https://github.com/plz/E-Series-Graphite-Grafana/tree/master/grafana-dashboards](https://github.com/plz/E-Series-Graphite-Grafana/tree/master/grafana-dashboards)

参考までにダッシュボードインポートの機能を説明します。

ダッシュボードのインポート方法は Grafana ログイン後に「Home」をクリックするとダッシュボードのインポート機能があります。




![image](/posts/2017-03-23_eseries-grafanagraphite-integration/images/6.png#layoutTextWidth)

ダッシュボードインポート画面



インポートボタンをクリックすると jsonファイルをアップロードできるのでこの機能を使ってGrafanaにダッシュボードを追加します。




![image](/posts/2017-03-23_eseries-grafanagraphite-integration/images/7.png#layoutTextWidth)

ダッシュボードインポート画面



#### トラブルシューティング

動作しないときの切り分けです。

*   E-Series コレクタが動いているか
*   ディスク容量が不足していないか
*   WSP の wsconfig.xml に設定されている stats.poll.save.history の設定値によってはメトリックス取得の頻度、保管期間によっては WSP で HTTP 503 エラーが発生しメトリックスが取得できなくなります。

#### E-Series のコレクタが動いているか？

Systemctl のサービスとして登録しているのであれば以下のコマンドでログを確認
``journalctl -xef -u eseries-metrics-collector``

E-Series collectorが動作している場合は以下のスクリーンショットのように Graphite にStatistics が登録されています。


![image](/posts/2017-03-23_eseries-grafanagraphite-integration/images/8.png#layoutTextWidth)

GraphiteにE-Series の Statistics が登録されていることを確認



#### WebService Proxy に対象のE-Series を登録しているか

#### 確認方法
``$ curl -X GET --header &#39;Accept: application/json&#39; &#39;http://10.128.221.213:8080/devmgr/v2/storage-systems&#39; -u ro | jq .``

#### 実行結果

上記コマンドの結果を記載します。
``$ curl -X GET --header &#39;Accept: application/json&#39; &#39;http://10.128.221.213:8080/devmgr/v2/storage-systems&#39; -u ro | jq .  
Enter host password for user &#39;ro&#39;:  
 % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current  
								 Dload  Upload   Total   Spent    Left  Speed  
100  1582  100  1582    0     0  32308      0 --:--:-- --:--:-- --:--:-- 32958  
’[  
 {  
	&#34;id&#34;: &#34;1&#34;,  
	        &#34;name&#34;: &#34;nsc-e5660-02&#34;,  
	        &#34;wwn&#34;: &#34;60080E500029C65800000000567C8CB3&#34;,  
	        &#34;passwordStatus&#34;: &#34;valid&#34;,  
	        &#34;passwordSet&#34;: true,  
	        &#34;status&#34;: &#34;optimal&#34;,  
	        &#34;ip1&#34;: &#34;10.128.223.45&#34;,  
	        &#34;ip2&#34;: &#34;10.128.223.46&#34;,  
	        &#34;managementPaths&#34;: [  
	          &#34;10.128.223.45&#34;,  
	          &#34;10.128.223.46&#34;  
	        ],  
	        &#34;driveCount&#34;: 60,  
	        &#34;trayCount&#34;: 1,  
	        &#34;traceEnabled&#34;: false,  
	        &#34;types&#34;: &#34;&#34;,  
	        &#34;model&#34;: &#34;5600&#34;,  
	        &#34;metaTags&#34;: [],  
	        &#34;hotSpareSize&#34;: &#34;0&#34;,  
	        &#34;usedPoolSpace&#34;: &#34;118747255799808&#34;,  
	        &#34;freePoolSpace&#34;: &#34;16355235463168&#34;,  
	        &#34;unconfiguredSpace&#34;: &#34;0&#34;,  
	        &#34;driveTypes&#34;: [  
	          &#34;sas&#34;  
	        ],  
	        &#34;hostSpareCountInStandby&#34;: 0,  
	        &#34;hotSpareCount&#34;: 0,  
	        &#34;hostSparesUsed&#34;: 0,  
	        &#34;bootTime&#34;: &#34;2017-02-07T03:23:13.000+0000&#34;,  
	        &#34;fwVersion&#34;: &#34;08.30.01.00&#34;,  
	        &#34;appVersion&#34;: &#34;08.30.01.00&#34;,  
	        &#34;bootVersion&#34;: &#34;08.30.01.00&#34;,  
	        &#34;nvsramVersion&#34;: &#34;N5600-830834-D01&#34;,  
	        &#34;chassisSerialNumber&#34;: &#34;1203FGK04651&#34;,  
	        &#34;accessVolume&#34;: {  
	          &#34;enabled&#34;: true,  
	          &#34;volumeHandle&#34;: 16384,  
	          &#34;capacity&#34;: &#34;20971520&#34;,  
	          &#34;accessVolumeRef&#34;: &#34;2100000060080E5000437864000039EA5898DF68&#34;,  
	          &#34;reserved1&#34;: &#34;&#34;,  
	          &#34;objectType&#34;: &#34;accessVolume&#34;,  
	          &#34;name&#34;: &#34;Access&#34;,  
	          &#34;id&#34;: &#34;2100000060080E5000437864000039EA5898DF68&#34;,  
	          &#34;wwn&#34;: &#34;&#34;,  
	          &#34;preferredControllerId&#34;: &#34;&#34;,  
	          &#34;totalSizeInBytes&#34;: &#34;0&#34;,  
	          &#34;listOfMappings&#34;: [],  
	          &#34;mapped&#34;: false,  
	          &#34;currentControllerId&#34;: &#34;&#34;  
	        },  
	        &#34;unconfiguredSpaceByDriveType&#34;: {},  
	        &#34;mediaScanPeriod&#34;: 30,  
	        &#34;driveChannelPortDisabled&#34;: false,  
	        &#34;recoveryModeEnabled&#34;: false,  
	        &#34;autoLoadBalancingEnabled&#34;: true,  
	        &#34;remoteMirroringEnabled&#34;: false,  
	        &#34;fcRemoteMirroringState&#34;: &#34;disabled&#34;,  
	        &#34;asupEnabled&#34;: true,  
	        &#34;securityKeyEnabled&#34;: false,  
	        &#34;lastContacted&#34;: &#34;2017-02-24T09:21:54.097+0000&#34;,  
	        &#34;definedPartitionCount&#34;: 4,  
	        &#34;simplexModeEnabled&#34;: false,  
	        &#34;freePoolSpaceAsString&#34;: &#34;16355235463168&#34;,  
	        &#34;hotSpareSizeAsString&#34;: &#34;0&#34;,  
	        &#34;unconfiguredSpaceAsStrings&#34;: &#34;0&#34;,  
	        &#34;usedPoolSpaceAsString&#34;: &#34;118747255799808&#34;  
	      }  
]``

#### WSP への追加方法

WebService ProxyからE-Seriesを管理するためには、WSP の管理対象として E-Series を追加する必要があります。
``$ curl -X POST --header &#39;Content-Type: application/json&#39; --header &#39;Accept: text/html&#39; -d &#39;{  
 &#34;id&#34;: &#34;2&#34;,  
 &#34;controllerAddresses&#34;: [  
	&#34;10.128.219.103”,   
	&#34;10.128.219.104&#34;,   
 ],  
 &#34;password&#34;: &#34;password&#34;,  
}&#39; &#39;http://10.128.221.213:8080/devmgr/v2/storage-systems&#39; -u rw``

#### まとめ

今回は E-Series Graphite Grafana 連携を紹介しました。E-Seriesの性能評価を行う際にわかりやすく可視化し、長期間性能を取得したい場合に活用いただけるものとなります。Grafana との連携により既存のダッシュボード監視にストレージ監視を統合することができるようになります。
