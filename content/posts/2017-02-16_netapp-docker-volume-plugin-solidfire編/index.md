---
title: "NetApp Docker Volume Plugin (SolidFire編)"
author: "makotow"
date: 2017-02-16T05:59:51.534Z
lastmod: 2020-01-04T01:41:53+09:00

description: ""

subtitle: "12分で SolidFire Docker Volume Plugin を使う"
tags:
 - Tech
 - Netapp
 - Infrastructure
 - Docker
 - Docker Volume

image: "/posts/2017-02-16_netapp-docker-volume-plugin-solidfire編/images/1.png" 
images:
 - "/posts/2017-02-16_netapp-docker-volume-plugin-solidfire編/images/1.png"
 - "/posts/2017-02-16_netapp-docker-volume-plugin-solidfire編/images/2.png"
 - "/posts/2017-02-16_netapp-docker-volume-plugin-solidfire編/images/3.png"
 - "/posts/2017-02-16_netapp-docker-volume-plugin-solidfire編/images/4.png"


aliases:
    - "/netapp-docker-volume-plugin-solidfire%E7%B7%A8-5163b0d65ba3"

---

#### 12分で SolidFire Docker Volume Plugin を使う

**2017/7/27 追記時点では以下のURLの情報が最新です。**

### [Docker Managed Plugin でNetApp Docker Volume Plugin (ONTAP, SolidFire) を試す](https://medium.com/makotows-blog/docker-managed-plugin-system-ndvp-ac6aa362aa5b)前回([nDVP ONTAP編](http://www.netapp.com/jp/communities/tech-ontap/jp-tot-201612-netapp-docker.aspx))に引き続き、SolidFire編となります。

docker のバージョン、ホストOS, nDVP などのインストールは 前回([nDVP ONTAP編](http://www.netapp.com/jp/communities/tech-ontap/jp-tot-201612-netapp-docker.aspx))と同様の環境で行います。

今回は DockerホストからSolidFireの設定、Docker Volume を SolidFire上に作成する方法について説明します。

SolidFire 自体をご存知無い方は以下の記事を読んでいただくことをおすすめ致します。

*   [SolidFire：次世代データセンターのためのオールフラッシュ](http://www.netapp.com/jp/communities/tech-ontap/jp-201607-tot-solidfire-all-flash-for-the-next-generation-data-center.aspx)

NetApp のフラッシュストレージの使い分けについては過去の記事が参考になります。

*   [最適なフラッシュ システムを選択するためのアプリケーション ニーズの優先順位付け](http://www.netapp.com/jp/communities/tech-ontap/jp-201608-tot-choosing-the-right-flash.aspx)

#### NetApp Docker Volume Plugin とは( 前回と同じ内容）

NetApp が提供しているすべてのフラッシュストレージ (All Flash FAS, E-series, SolidFire) を Docker へ統合し Docker Engine を拡張出来るようにしたものです。

nDVP の実現には Docker 社から提供されている Docker Volume Plugin という仕組みを使用しています。Docker Volume Plugin は永続化の仕組み である「 Docker Volume 」 のデータ保存先をホストOSだけではなく外部ストレージへのデータ永続化を提供する仕組みです。

当初は Docker からホスト OS 上にデータを永続化する仕組みを提供していましたが、 Docker version 1.8 から Docker Volume の保存先を外部ストレージへ永続化できるようにプラグインフレームワーク (Docker Volume Plugin) が提供されました。（図１：Docker Volume Plugin と nDVP の関係）


![図１: Docker Volume Plugin と nDVP の関係](/posts/2017-02-16_netapp-docker-volume-plugin-solidfire編/images/1.png#layoutTextWidth)

図１: Docker Volume Plugin と nDVP の関係



nDVP は Docker ホストOSに対してストレージリソースのプロビジョニング・管理をサポートしています。  
主な機能としては以下の通りです。

*   ストレージリソースのプロビジョニング/デプロビジョニング
*   ボリューム(Docker Volume, FlexVol)の作成・削除）
*   Docker Volume と FlexVol の紐付け
*   作成したFlexVolに対してデータ管理機能の設定
*   Docker ホストOS に対するボリュームの自動マウント/アンマウント

上記の機能を使用することで Docker Volume を使用する感覚で Docker コンテナから外部ストレージ(ONTAP FlexVol)へのデータ永続化を可能とします。

#### Docker Volume Plugin を使用するまでの流れ

*   Docker ホストOS設定 (必要パッケージのインストール )
*   nDVP の conf ファイル設定
*   nDVP SolidFire の起動
*   docker volume の作成
*   docker 起動

今回は curl を使用して REST API のリクエストを発行します、返り値は json となります。今回はREST APIの結果を見やすくするため jq を使用します。
``apt-get intall jq``

#### 検証環境(SolidFire クラスタの追加）

今回使用する環境は以下の通りです。（図２: 検証環境) クライアント部分は前回と同じです。 SolidFire クラスタが追加になりました。


![image](/posts/2017-02-16_netapp-docker-volume-plugin-solidfire編/images/2.png#layoutTextWidth)

図２: 検証環境



nDVP で使用する SolidFire の IP は以下の２つです。

マネジメント用の MVIP、ストレージ通信用のSVIP になります。

*   MVIP:192.168.199.224
*   SVIP:192.168.199.225

#### SolidFire ユーザアカウント設定

SolidFire のコンフィグレーションは WebUI からオペレーションを行うか、REST API を使用してオペレーションを行います。

今回は REST API を使用してアカウントを作成します。

任意の作業ディレクトリに以下の json ファイルを作成してください。

json ファイル (create-account.json) を作成し curl で実行します。
``{  
        ”method&#34;: &#34;AddAccount&#34;,  
        ”params&#34;: {  
		&#34;username&#34;: &#34;docker&#34;,  
            &#34;attributes&#34;: “”,   
        },  
        &#34;id&#34;: 1  
}``

実行コマンド
``$ curl -k -X POST -H &#34;Content-type: application/json-rpc&#34; --data @create-account.json &#34;https://admin:solidfire@192.168.199.224/json-rpc/7.0&#34; | jq .````{  
        &#34;id&#34;: 1,  
        ”result&#34;: {  
                &#34;accountID&#34;: 1  
	}  
}``

作成できたことをREST API から確認します。

json ファイル (get-account.json) を作成し curl で実行します。
``{  
        &#34;method&#34;: &#34;GetAccountByName&#34;,  
        &#34;params&#34;: {  
                &#34;username&#34;: &#34;docker&#34;  
        },  
        &#34;id&#34;: 1  
}``

実行コマンド
``$ curl -k -X POST -H &#34;Content-type: application/json-rpc&#34; --data @get-account.json &#34;https://admin:solidfire@192.168.199.224/json-rpc/7.0&#34; | jq .````{  
    &#34;id&#34;: 1,  
    &#34;result&#34;: {  
        &#34;account&#34;: {  
            &#34;accountID&#34;: 1,  
            &#34;attributes&#34;: {},  
            &#34;initiatorSecret&#34;: &#34;e!%V(17DkZH5[cen&#34;,  
            &#34;status&#34;: &#34;active&#34;,  
            &#34;targetSecret&#34;: &#34;7!##H8KzA6wQ3lmY&#34;,  
            &#34;username&#34;: &#34;docker&#34;,  
            &#34;volumes&#34;: []  
        }  
    }  
}``

WebUI から確認すると以下のように docker ユーザが作成されています。


![image](/posts/2017-02-16_netapp-docker-volume-plugin-solidfire編/images/3.png#layoutTextWidth)



#### Docker ホストOSの設定

iscsi 接続をするために必要なパッケージを導入します。
``sudo apt-get -y install open-iscsi``

#### NetApp docker volume plugin の設定

SolidFire用の設定ファイルを記載します。

以下のパスに jsonファイルを作成します。内容は以下の通りです。

*   /etc/netappdvp/solidfire.json``{  
       &#34;version&#34;: 1,  
       &#34;storageDriverName&#34;: &#34;solidfire-san&#34;,  
       &#34;debug&#34;: true,  
       &#34;Endpoint&#34;: &#34;https://admin:solidfire@192.168.199.224/json-rpc/7.0&#34;,  
       &#34;SVIP&#34;: &#34;192.168.199.225:3260&#34;,  
       &#34;TenantName&#34;: &#34;docker&#34;,  
       &#34;DefaultVolSz&#34;: 1,  
       &#34;InitiatorIFace&#34;: &#34;default&#34;,  
       &#34;Types&#34;: [  
	       {  
	                &#34;Type&#34;: &#34;Bronze&#34;,  
	                &#34;QoS&#34;: {  
                                &#34;minIOPS&#34;: 1000,  
	                        &#34;maxIOPS&#34;: 2000,  
	                        &#34;burstIOPS&#34;: 4000  
                        }  
               },  
               {  
                       &#34;Type&#34;: &#34;Silver&#34;,  
                       &#34;Qos&#34;: {  
                                &#34;minIOPS&#34;: 4000,  
                                &#34;maxIOPS&#34;: 6000,  
                                &#34;burstIOPS&#34;: 8000  
                       }  
               },  
	       {  
                      &#34;Type&#34;: &#34;Gold&#34;,  
                      &#34;Qos&#34;: {  
                               &#34;minIOPS&#34;: 6000,  
                               &#34;maxIOPS&#34;: 8000,  
                               &#34;burstIOPS&#34;: 10000  
                      }  
               }  
        ]  
}``

パラメータについて説明します。

*   TenantName: 「SolidFire ユーザアカウント設定」で作成したユーザとなります。今回は「docker」としました。
*   DefaultVolSz: オプションでボリュームサイズを指定しなかった場合に使用されるデフォルトサイズ。
*   InitiatorIFace: iSCSI 通信を行うネットワークインターフェースを指定します。今回はインターフェースを１つのみの準備のため “default”としています。
*   Types: docker volume 作成時に指定できる QoS のタイプ。ここではサービスカタログとしてボリュームのQoSを定義しています。

ndvp を起動します。
``/etc/netappdvp$ sudo netappdvp --volume-driver=solidfire-san --config=/etc/netappdvp/solidfire.json&amp;  
[1] 4403  
/etc/netappdvp$ INFO[0000] Successfully initialized SolidFire Docker driver version 1.3``

**Successfully initialized** で作成成功です。

SolidFire のボリュームを作成して、docker 起動時にコンテナにマウントします。

-o でオプション指定が可能で type=XXXX で solidfire.json に定義したボリュームのQoSタイプを指定できます。 size=XX でボリュームのサイズを指定します。

例として、サイズ10GBで MinQoS 6000IOPS、MaxQoS 8000IOPS、 BurstIOPS 10000IOPS のボリュームを作成します。
``$ sudo docker volume create --driver solidfire-san --name vol-solid-1 -o size=10 -o type=Gold   
vol-solid-1  
$ cd /etc/netappdvp  
$ ls  
ontap-nas.json  solidfire.json  
$ sudo docker volume ls  
DRIVER              VOLUME NAME  
solidfire-san       vol-solid-1  
ontap-nas           vol1  
ontap-nas           vol2  
ontap-nas           vol3``

Web UI からQoSの設定状況を確認します。(4kbのQoS が Gold で定義しているものになっている)




![image](/posts/2017-02-16_netapp-docker-volume-plugin-solidfire編/images/4.png#layoutTextWidth)

コンテナ起動とボリュームマウントをします。

永続化できていることを確認するためファイルの作成をします。
``/etc/netappdvp$ sudo docker run --rm -it --volume-driver solidfire-san --volume vol-solid-1:/mnt alpine ash  
/ # ls  
bin      dev      etc      home     lib      linuxrc  media    mnt      proc     root     run      sbin     srv      sys      tmp      usr      var  
/ # cd mnt  
/mnt # touch test  
/mnt # ls  
lost+found  test  
/mnt # echo &#34;persistent storage&#34; &gt; test  
/mnt # exit``

一度コンテナを削除した後に上記で書き込んだテストファイルが存在するか、内容が永続化されているかを確認します。
``/etc/netappdvp$ sudo docker ps  
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES  
/etc/netappdvp$ sudo docker ps -a  
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES  
/etc/netappdvp$ sudo docker run --rm -it --volume-driver solidfire-san --volume vol-solid-1:/mnt alpine ash  
/ # cd /mnt  
/mnt # ls  
lost+found  test  
/mnt # cat test  
persistent storage  
/mnt #``

/mnt/test ファイルが存在し、内容が永続化されていることを確認できました。

#### エラー発生時の対処方法

solidfire docker voluem plugin の以下のログファイルに出力されています。

*   /var/log/netappdvp/solidfire-san.log

#### 技術情報

*   [Volume Options with the NetApp Docker Volume Plugin](https://netapp.github.io/blog/2016/06/16/volume-options-with-the-netapp-docker-volume-plugin/)
*   [Announcing the NetApp Docker Volume Plugin SolidFire Driver](https://netapp.github.io/blog/2016/06/29/announcing-netapp-docker-volume-plugin-solidfire-driver/)

#### まとめ

ここまで10分程度で読めたかと思います。

実際に設定を行い、 docker volume plugin からSolidFire上にボリュームを作成するまで１時間もかからずできます。

NetApp Docker Volume Plugin を使用することでdocker volume から透過的に SolidFire のボリュームを使用することができ堅牢なデータ永続化を提供します。
