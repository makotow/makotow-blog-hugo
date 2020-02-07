---
title: "Ansible の実行以前の話"
author: "makotow"
date: 2017-06-11T16:14:14.977Z
lastmod: 2020-01-05T03:11:13+09:00

description: ""

subtitle: "いまさらSSHの設定を見直してみた"
slug: 
tags:
 - Ansible
 - Tech

series:
-
categories:
-
image: "/posts/2017/06/11/ansible-の実行以前の話/images/1.png" 
images:
 - "/posts/2017/06/11/ansible-の実行以前の話/images/1.png"


aliases:
    - "/ansible-%E3%81%AE%E5%AE%9F%E8%A1%8C%E4%BB%A5%E5%89%8D%E3%81%AE%E8%A9%B1-f2fcffc94a96"

---

#### いまさらSSHの設定を見直してみた




![image](/posts/2017/06/11/ansible-の実行以前の話/images/1.png#layoutTextWidth)



Ansible の設定を行うついでにSSHの設定を見直して手順をクリアにしてみた。

あまりやらない作業であるがやるたびに検索し、何かしらにはまっているのでここにメモとして残す。

参考にした記事は以下の２個

*   [http://qiita.com/kentarosasaki/items/aa319e735a0b9660f1f0](http://qiita.com/kentarosasaki/items/aa319e735a0b9660f1f0)
*   [http://qiita.com/taka379sy/items/331a294d67e02e18d68d](http://qiita.com/taka379sy/items/331a294d67e02e18d68d)

#### 鍵認証を有効にする

まずは鍵の生成
`$ ssh-keygen  
`## パスワードなし認証するのでパスフレーズなしとする  
## 公開鍵、秘密鍵が作成される``

作成された公開鍵を ansible でプロビジョニングするホストへ配布
``$ ssh-copy-id -i ~/.ssh/id_rsa.pub host_name_or_IP  
## `ssh-copy-idは公開鍵をコピーして、authorized_keysにも登録してくれる便利コマンド`

#### Ansible 用の設定

Ansibleの設定ファイルはplaybook配下にansible.cfg を配置。
``/path/to/playbook/ansible.cfg``

Ansibleで指定するホストファイルに存在するホストはすべて信頼できるホストであることを前提として、以下の通りssh_args を設定する。
``ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null``

Ansibleのプロビジョニング対象となるホストではsshdの設定を変更
``$ sudo vi /etc/ssh/sshd_config  
AuthorizedKeysFile のコメントアウト解除``
