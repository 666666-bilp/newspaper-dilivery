-- =====================================================
-- 报纸发行员投递管理系统 - 数据库初始化脚本
-- 包含：建库建表、约束、索引、视图、存储过程、触发器、用户权限、测试数据
-- =====================================================

CREATE DATABASE IF NOT EXISTS newspaper_delivery DEFAULT CHARACTER SET utf8mb4;
USE newspaper_delivery;

-- =====================================================
-- 一、创建表结构（含主键、外键、检查约束、默认值）
-- =====================================================

-- 1. 系统用户表
CREATE TABLE IF NOT EXISTS sys_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT '管理员' CHECK (role IN ('管理员','操作员')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. 社区表
CREATE TABLE IF NOT EXISTS community (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. 发行员表
CREATE TABLE IF NOT EXISTS deliverer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    id_card CHAR(18) CHECK (LENGTH(id_card) = 18),
    status VARCHAR(10) NOT NULL DEFAULT '在职' CHECK (status IN ('在职','离职')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. 客户表
CREATE TABLE IF NOT EXISTS customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(200),
    community_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (community_id) REFERENCES community(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 5. 报纸表
CREATE TABLE IF NOT EXISTS newspaper (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    type VARCHAR(20) DEFAULT '日报' CHECK (type IN ('日报','周报','月报','季刊')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 6. 发行区域表（发行员-社区 多对多）
CREATE TABLE IF NOT EXISTS delivery_area (
    id INT AUTO_INCREMENT PRIMARY KEY,
    deliverer_id INT NOT NULL,
    community_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    FOREIGN KEY (deliverer_id) REFERENCES deliverer(id) ON DELETE CASCADE,
    FOREIGN KEY (community_id) REFERENCES community(id) ON DELETE CASCADE,
    UNIQUE KEY uk_deliverer_community (deliverer_id, community_id)
) ENGINE=InnoDB;

-- 7. 订阅表
CREATE TABLE IF NOT EXISTS subscription (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    newspaper_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(10) NOT NULL DEFAULT '订阅中' CHECK (status IN ('订阅中','已退订')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE RESTRICT,
    FOREIGN KEY (newspaper_id) REFERENCES newspaper(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 8. 审计日志表
CREATE TABLE IF NOT EXISTS audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    record_id INT,
    old_data TEXT,
    new_data TEXT,
    operate_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator VARCHAR(50)
) ENGINE=InnoDB;

-- =====================================================
-- 二、【高阶技术4】索引优化
-- =====================================================

-- 复合索引：加速按客户+报纸查询订阅
CREATE INDEX idx_sub_customer_newspaper ON subscription(customer_id, newspaper_id);
-- 唯一索引已在 delivery_area 中创建
-- 外键索引加速关联查询
CREATE INDEX idx_customer_community ON customer(community_id);
CREATE INDEX idx_sub_status ON subscription(status);
CREATE INDEX idx_deliverer_status ON deliverer(status);

-- =====================================================
-- 三、【高阶技术3】视图
-- =====================================================

-- 视图1：发行员工作量视图（发行员 + 负责社区数 + 客户总数 + 订阅总数）
CREATE OR REPLACE VIEW v_deliverer_workload AS
SELECT
    d.id AS deliverer_id,
    d.name AS deliverer_name,
    d.phone,
    d.status,
    COUNT(DISTINCT da.community_id) AS community_count,
    COUNT(DISTINCT c.id) AS customer_count,
    COUNT(DISTINCT s.id) AS subscription_count
FROM deliverer d
LEFT JOIN delivery_area da ON d.id = da.deliverer_id
LEFT JOIN customer c ON da.community_id = c.community_id
LEFT JOIN subscription s ON c.id = s.customer_id AND s.status = '订阅中'
GROUP BY d.id, d.name, d.phone, d.status;

-- 视图2：订阅详情视图（隐藏用户敏感字段，联表展示）
CREATE OR REPLACE VIEW v_subscription_detail AS
SELECT
    s.id AS sub_id,
    c.name AS customer_name,
    c.phone AS customer_phone,
    com.name AS community_name,
    n.name AS newspaper_name,
    n.price,
    s.quantity,
    s.start_date,
    s.end_date,
    s.status,
    (n.price * s.quantity) AS total_amount
FROM subscription s
JOIN customer c ON s.customer_id = c.id
JOIN newspaper n ON s.newspaper_id = n.id
JOIN community com ON c.community_id = com.id;

-- =====================================================
-- 四、【高阶技术1】存储过程（带输入/输出参数）
-- =====================================================

DELIMITER //

-- 存储过程：月度统计报表（输入：月、年；输出：客户总数、订阅总数、收入总额）
CREATE PROCEDURE sp_monthly_stats(
    IN p_month INT,
    IN p_year INT,
    OUT p_total_customers INT,
    OUT p_total_subscriptions INT,
    OUT p_total_revenue DECIMAL(12,2)
)
BEGIN
    SELECT COUNT(*) INTO p_total_customers FROM customer
    WHERE YEAR(created_at) = p_year AND MONTH(created_at) <= p_month;

    SELECT COUNT(*) INTO p_total_subscriptions FROM subscription
    WHERE status = '订阅中'
      AND YEAR(created_at) = p_year AND MONTH(created_at) <= p_month;

    SELECT COALESCE(SUM(n.price * s.quantity), 0) INTO p_total_revenue
    FROM subscription s
    JOIN newspaper n ON s.newspaper_id = n.id
    WHERE s.status = '订阅中'
      AND YEAR(s.created_at) = p_year AND MONTH(s.created_at) <= p_month;
END //

-- Stored procedure: deliverer performance stats by year
CREATE PROCEDURE sp_deliverer_performance(IN p_year INT)
BEGIN
    SELECT
        d.name AS deliverer_name,
        COUNT(DISTINCT c.id) AS customer_count,
        COUNT(DISTINCT s.id) AS subscription_count,
        COALESCE(SUM(n.price * s.quantity), 0) AS total_revenue
    FROM deliverer d
    LEFT JOIN delivery_area da ON d.id = da.deliverer_id
    LEFT JOIN customer c ON da.community_id = c.community_id
    LEFT JOIN subscription s ON c.id = s.customer_id AND s.status = '订阅中'
    LEFT JOIN newspaper n ON s.newspaper_id = n.id
    WHERE d.status = '在职' AND YEAR(s.created_at) = p_year
    GROUP BY d.id, d.name
    ORDER BY total_revenue DESC;
END //

DELIMITER ;

-- =====================================================
-- 五、【高阶技术2】触发器
-- =====================================================

DELIMITER //

-- 触发器1：订阅变更自动记录审计日志（INSERT）
CREATE TRIGGER trg_subscription_insert
AFTER INSERT ON subscription FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name, operation, record_id, new_data, operator)
    VALUES ('subscription', 'INSERT', NEW.id,
            CONCAT('customer_id=', NEW.customer_id, ',newspaper_id=', NEW.newspaper_id,
                   ',quantity=', NEW.quantity, ',status=', NEW.status),
            'system');
END //

-- 触发器2：订阅变更自动记录审计日志（UPDATE）
CREATE TRIGGER trg_subscription_update
AFTER UPDATE ON subscription FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name, operation, record_id, old_data, new_data, operator)
    VALUES ('subscription', 'UPDATE', NEW.id,
            CONCAT('status=', OLD.status, ',quantity=', OLD.quantity),
            CONCAT('status=', NEW.status, ',quantity=', NEW.quantity),
            'system');
END //

-- 触发器3：删除客户前自动归档其订阅记录到审计日志
CREATE TRIGGER trg_customer_before_delete
BEFORE DELETE ON customer FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name, operation, record_id, old_data, operator)
    VALUES ('customer', 'DELETE', OLD.id,
            CONCAT('name=', OLD.name, ',phone=', OLD.phone, ',address=', OLD.address),
            'system');
    -- 先删除关联订阅
    DELETE FROM subscription WHERE customer_id = OLD.id;
END //

DELIMITER ;

-- =====================================================
-- 六、【高阶技术6】用户权限管理
-- =====================================================

-- 删除旧用户（忽略错误）
DROP USER IF EXISTS 'nd_admin'@'localhost';
DROP USER IF EXISTS 'nd_readonly'@'localhost';

-- 创建管理员用户（全部权限）
CREATE USER 'nd_admin'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON newspaper_delivery.* TO 'nd_admin'@'localhost';

-- 创建只读用户（仅SELECT权限）
CREATE USER 'nd_readonly'@'localhost' IDENTIFIED BY 'readonly123';
GRANT SELECT ON newspaper_delivery.* TO 'nd_readonly'@'localhost';
-- 只读用户也可以查看视图
GRANT SELECT ON newspaper_delivery.v_deliverer_workload TO 'nd_readonly'@'localhost';
GRANT SELECT ON newspaper_delivery.v_subscription_detail TO 'nd_readonly'@'localhost';

FLUSH PRIVILEGES;

-- =====================================================
-- 七、插入测试数据
-- =====================================================

-- 系统用户
INSERT INTO sys_user(username, password, role) VALUES
('admin', '123456', '管理员'),
('zhangwei', '123456', '操作员');

-- 社区（6个，基于杭州真实社区名）
INSERT INTO community(name, address) VALUES
('春江花月社区', '上城区之江路128号'),
('彩虹城社区', '滨江区滨盛路888号'),
('翠苑一区社区', '西湖区文一路258号'),
('万家花城社区', '拱墅区莫干山路966号'),
('良渚文化村社区', '余杭区良渚街道文化路88号'),
('汇宇花园社区', '萧山区通惠南路168号');

-- 发行员（6人，杭州本地常见姓名风格）
INSERT INTO deliverer(name, phone, id_card, status) VALUES
('刘建国', '13867102345', '330102197805122356', '在职'),
('陈秀英', '13867105678', '330103198503181245', '在职'),
('王志刚', '13758214567', '330105199006063478', '在职'),
('赵美华', '13675891234', '330106198802287654', '在职'),
('李明辉', '18958126789', '330102199508154321', '在职'),
('周雪莲', '15068123456', '330103197511091234', '离职');

-- 客户（18人，分布在6个社区，含老年人、上班族、家庭主妇等角色）
INSERT INTO customer(name, phone, address, community_id) VALUES
('陈大爷', '13957102345', '之江路128号3-101', 1),       -- 春江花月社区 退休老人
('沈美琴', '13957102346', '之江路128号5-202', 1),       -- 春江花月社区 家庭主妇
('陆先生', '13957102347', '之江路128号8-401', 1),       -- 春江花月社区 上班族
('徐阿婆', '13957103456', '滨盛路888号1-102', 2),       -- 彩虹城社区 独居老人
('何建国', '13957103457', '滨盛路888号6-301', 2),       -- 彩虹城社区 退休教师
('蒋晓芳', '13957103458', '滨盛路888号9-502', 2),       -- 彩虹城社区 年轻白领
('丁伯伯', '13957104567', '文一路258号2-103', 3),       -- 翠苑一区社区 退休工人
('潘美云', '13957104568', '文一路258号4-201', 3),       -- 翠苑一区社区 全职妈妈
('宋志远', '13957104569', '文一路258号7-302', 3),       -- 翠苑一区社区 自由职业
('韩阿姨', '13957105678', '莫干山路966号3-101', 4),     -- 万家花城社区 退休护士
('高博文', '13957105679', '莫干山路966号5-401', 4),     -- 万家花城社区 IT工程师
('许丽萍', '13957105680', '莫干山路966号8-202', 4),     -- 万家花城社区 书法老师
('钟奶奶', '13957106789', '文化路88号1-101', 5),       -- 良渚文化村 退休
('陶志明', '13957106790', '文化路88号2-301', 5),       -- 良渚文化村 设计师
('戴小红', '13957106791', '文化路88号4-102', 5),       -- 良渚文化村 花店店主
('范伯伯', '13957107890', '通惠南路168号2-101', 6),    -- 汇宇花园 退休干部
('方丽华', '13957107891', '通惠南路168号5-201', 6),    -- 汇宇花园 会计
('俞文斌', '13957107892', '通惠南路168号7-301', 6);    -- 汇宇花园 个体商户

-- 报纸（8种，真实报纸名称和定价）
INSERT INTO newspaper(name, price, stock, type) VALUES
('人民日报', 1.80, 500, '日报'),
('钱江晚报', 1.20, 800, '日报'),
('都市快报', 1.50, 600, '日报'),
('参考消息', 0.80, 400, '日报'),
('南方周末', 3.00, 300, '周报'),
('健康时报', 2.70, 200, '周报'),
('经济观察报', 5.00, 150, '周报'),
('三联生活周刊', 12.00, 100, '周刊');

-- 发行区域（发行员负责社区分配，模拟真实片区划分）
INSERT INTO delivery_area(deliverer_id, community_id, assigned_date) VALUES
(1, 1, '2025-03-01'),  -- 刘建国 → 春江花月社区
(1, 6, '2025-06-01'),  -- 刘建国 → 汇宇花园社区
(2, 2, '2025-03-01'),  -- 陈秀英 → 彩虹城社区
(3, 3, '2025-04-01'),  -- 王志刚 → 翠苑一区社区
(3, 4, '2025-07-01'),  -- 王志刚 → 万家花城社区
(4, 5, '2025-03-01'),  -- 赵美华 → 良渚文化村社区
(5, 3, '2025-09-01'),  -- 李明辉 → 翠苑一区社区（协助）
(5, 6, '2026-01-01');  -- 李明辉 → 汇宇花园社区（协助）

-- 订阅记录（22条，时间跨度从2025年至今，模拟真实订阅场景）
INSERT INTO subscription(customer_id, newspaper_id, quantity, start_date, status) VALUES
-- 春江花月社区（陈大爷 退休老人，爱看参考消息和健康时报；沈美琴 家庭主妇看都市快报；陆先生 上班族看经济观察报）
(1, 4, 1, '2025-03-01', '订阅中'),   -- 陈大爷 订参考消息
(1, 6, 1, '2025-03-01', '订阅中'),   -- 陈大爷 订健康时报
(2, 3, 1, '2025-04-01', '订阅中'),   -- 沈美琴 订都市快报
(2, 2, 1, '2025-06-01', '订阅中'),   -- 沈美琴 加订钱江晚报
(3, 7, 1, '2025-03-01', '订阅中'),   -- 陆先生 订经济观察报
(3, 1, 1, '2025-05-01', '已退订'),   -- 陆先生 试订人民日报后退订
-- 彩虹城社区（徐阿婆 独居老人订钱江晚报；何建国 退休教师；蒋晓芳 白领看三联）
(4, 2, 1, '2025-03-15', '订阅中'),   -- 徐阿婆 订钱江晚报
(5, 1, 1, '2025-04-01', '订阅中'),   -- 何建国 订人民日报
(5, 5, 1, '2025-04-01', '订阅中'),   -- 何建国 订南方周末
(6, 8, 1, '2025-05-01', '订阅中'),   -- 蒋晓芳 订三联生活周刊
-- 翠苑一区社区（丁伯伯 退休工人看参考消息；潘美云 全职妈妈看都市快报和健康时报；宋志远 自由职业）
(7, 4, 1, '2025-04-01', '订阅中'),   -- 丁伯伯 订参考消息
(8, 3, 1, '2025-05-01', '订阅中'),   -- 潘美云 订都市快报
(8, 6, 1, '2025-07-01', '订阅中'),   -- 潘美云 加订健康时报
(9, 5, 1, '2025-06-01', '订阅中'),   -- 宋志远 订南方周末
-- 万家花城社区（韩阿姨 退休护士看健康时报；高博文 IT工程师；许丽萍 书法老师）
(10, 6, 1, '2025-04-01', '订阅中'),  -- 韩阿姨 订健康时报
(10, 2, 1, '2025-08-01', '订阅中'),  -- 韩阿姨 加订钱江晚报
(11, 7, 1, '2025-05-01', '订阅中'),  -- 高博文 订经济观察报
(11, 8, 1, '2025-09-01', '订阅中'),  -- 高博文 加订三联生活周刊
(12, 1, 1, '2025-06-01', '已退订'),  -- 许丽萍 试订人民日报后退订
-- 良渚文化村（钟奶奶 退休；陶志明 设计师；戴小红 花店店主）
(13, 2, 1, '2025-04-15', '订阅中'),  -- 钟奶奶 订钱江晚报
(14, 7, 1, '2025-05-01', '订阅中'),  -- 陶志明 订经济观察报
(15, 3, 1, '2025-07-01', '订阅中'),  -- 戴小红 订都市快报
-- 汇宇花园（范伯伯 退休干部；方丽华 会计；俞文斌 个体商户）
(16, 5, 1, '2025-05-01', '订阅中'),  -- 范伯伯 订南方周末
(16, 1, 1, '2025-06-01', '订阅中'),  -- 范伯伯 加订人民日报
(17, 7, 1, '2025-08-01', '订阅中'),  -- 方丽华 订经济观察报
(18, 3, 1, '2025-09-01', '已退订');  -- 俞文斌 试订都市快报后退订

-- =====================================================
-- 验证：显示所有表
-- =====================================================
SELECT '=== Database init complete ===' AS message;
SHOW TABLES;
SELECT 'Advanced DB Features:' AS features;
SELECT '1.StoredProcedures: sp_monthly_stats, sp_deliverer_performance' AS item UNION ALL
SELECT '2.Triggers: trg_subscription_insert/update, trg_customer_before_delete' UNION ALL
SELECT '3.Views: v_deliverer_workload, v_subscription_detail' UNION ALL
SELECT '4.Indexes: idx_sub_customer_newspaper + 4 more' UNION ALL
SELECT '5.Transactions: see SubscriptionServlet.java' UNION ALL
SELECT '6.UserPermissions: nd_admin(full), nd_readonly(read)' UNION ALL
SELECT '7.WindowFunctions: see StatsServlet.java';
