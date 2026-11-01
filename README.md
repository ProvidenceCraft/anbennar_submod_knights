# Anbennar: Knights of Escann

安本纳尔（Anbennar-PublicFork）的独立子 mod。**不修改 Anbennar 本体的任何文件**，所有改动都以"新增文件 + 加载顺序覆盖"的方式实现。

## 目标

1. **王国骑士系统**：为 Escann 四个可复兴古国（Farraneán `B60`、Adenica `B58`、Castanor `B32`、Blademarches `B33`）提供一个共用政体改革，复用原版八旗机制：
   - 步兵 → **步行骑士**
   - 骑兵 → **骑士**
2. **国家专属特权**：每个国家一个独特特权，差异化各自的骑士。
3. **马尔霍德（Marrhold `B36`）**：把现有狮鹫骑士改成与 `marrodic` 文化绑定的通用改革，并提高可招募上限。

## 安装

把这两项复制到：

```
%USERPROFILE%\Documents\Paradox Interactive\Europa Universalis IV\mod\
```

- `anbennar_knights.mod`
- `anbennar_knights\`

然后在启动器里：**Anbennar-PublicFork 必须排在它前面**（`dependencies` 已声明，启动器通常会自动排序）。

## 目录结构

```
anbennar_knights.mod          # 外部描述文件
anbennar_knights/
├── descriptor.mod            # 内部描述文件
├── common/
│   ├── government_reforms/   # 骑士改革
│   ├── estate_privileges/    # 四国专属特权
│   └── units/                # 骑士兵种数值
├── localisation/             # 中英双语
└── docs/DESIGN.md            # 设计与研究记录
```

## 技术要点

- 八旗的开关是政府改革的 `custom_attributes = { eight_banners_buff = yes }`，不是文化硬编码。
- 兵种是普通的 `common/units/*.txt`，Anbennar 地图上不存在满洲文化，覆盖 `manchu_banner` / `han_banner` 不会影响任何现有国家。
- 翼骑兵（狮鹫骑士）走 `can_recruit_hussars` + `local_amount_of_hussars = 0.01`（每点发展度），100 发展度 = 1 队即来源于此；`amount_of_hussars` 提供额外固定队数。

## 状态

骨架阶段（v0.1.0）。设计细节见 `docs/DESIGN.md`。
