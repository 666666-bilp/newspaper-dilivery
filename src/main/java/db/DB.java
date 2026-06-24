package db;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import model.*;

public class DB {
    private static final String URL = System.getenv().getOrDefault("DB_URL",
        "jdbc:mysql://localhost:3306/newspaper_delivery?characterEncoding=UTF-8&serverTimezone=UTC");
    private static final String USER = System.getenv().getOrDefault("DB_USER", "root");
    private static final String PWD = System.getenv().getOrDefault("DB_PASSWORD", "2720578364....");

    static {
        try { Class.forName("com.mysql.cj.jdbc.Driver"); }
        catch (ClassNotFoundException e) { throw new RuntimeException(e); }
    }

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PWD);
    }

    // ==================== 系统用户 ====================
    public SysUser login(String username, String password) {
        String sql = "SELECT * FROM sys_user WHERE username=? AND password=?";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapSysUser(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean addSysUser(SysUser u) {
        String sql = "INSERT INTO sys_user(username, password, role) VALUES(?,?,?)";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setString(1, u.getUsername());
            ps.setString(2, u.getPassword());
            ps.setString(3, u.getRole());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean changePassword(int id, String newPwd) {
        String sql = "UPDATE sys_user SET password=? WHERE id=?";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setString(1, newPwd);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean deleteSysUser(int id) {
        String sql = "DELETE FROM sys_user WHERE id=?";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public ArrayList<SysUser> listSysUsers() {
        ArrayList<SysUser> list = new ArrayList<>();
        String sql = "SELECT * FROM sys_user";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapSysUser(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ==================== 社区 ====================
    public ArrayList<Community> listCommunities() {
        ArrayList<Community> list = new ArrayList<>();
        String sql = "SELECT * FROM community ORDER BY id";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Community c = new Community();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setAddress(rs.getString("address"));
                list.add(c);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean addCommunity(Community c) {
        String sql = "INSERT INTO community(name, address) VALUES(?,?)";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setString(1, c.getName());
            ps.setString(2, c.getAddress());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // ==================== 客户 CRUD ====================
    public ArrayList<Customer> listCustomers() {
        ArrayList<Customer> list = new ArrayList<>();
        String sql = "SELECT c.*, com.name AS community_name FROM customer c " +
                     "LEFT JOIN community com ON c.community_id = com.id ORDER BY c.id";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapCustomer(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public Customer getCustomer(int id) {
        String sql = "SELECT c.*, com.name AS community_name FROM customer c " +
                     "LEFT JOIN community com ON c.community_id = com.id WHERE c.id=?";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapCustomer(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean addCustomer(Customer c) {
        String sql = "INSERT INTO customer(name, phone, address, community_id) VALUES(?,?,?,?)";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setString(1, c.getName());
            ps.setString(2, c.getPhone());
            ps.setString(3, c.getAddress());
            ps.setInt(4, c.getCommunityId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateCustomer(Customer c) {
        String sql = "UPDATE customer SET name=?, phone=?, address=?, community_id=? WHERE id=?";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setString(1, c.getName());
            ps.setString(2, c.getPhone());
            ps.setString(3, c.getAddress());
            ps.setInt(4, c.getCommunityId());
            ps.setInt(5, c.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean deleteCustomer(int id) {
        String sql = "DELETE FROM customer WHERE id=?";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // ==================== 发行员 CRUD ====================
    public ArrayList<Deliverer> listDeliverers() {
        ArrayList<Deliverer> list = new ArrayList<>();
        String sql = "SELECT * FROM deliverer ORDER BY id";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapDeliverer(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean addDeliverer(Deliverer d) {
        String sql = "INSERT INTO deliverer(name, phone, id_card, status) VALUES(?,?,?,?)";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setString(1, d.getName());
            ps.setString(2, d.getPhone());
            ps.setString(3, d.getIdCard());
            ps.setString(4, d.getStatus() != null ? d.getStatus() : "在职");
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateDeliverer(Deliverer d) {
        String sql = "UPDATE deliverer SET name=?, phone=?, id_card=?, status=? WHERE id=?";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setString(1, d.getName());
            ps.setString(2, d.getPhone());
            ps.setString(3, d.getIdCard());
            ps.setString(4, d.getStatus());
            ps.setInt(5, d.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean deleteDeliverer(int id) {
        String sql = "DELETE FROM deliverer WHERE id=?";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // ==================== 报纸 CRUD ====================
    public ArrayList<Newspaper> listNewspapers() {
        ArrayList<Newspaper> list = new ArrayList<>();
        String sql = "SELECT * FROM newspaper ORDER BY id";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Newspaper n = new Newspaper();
                n.setId(rs.getInt("id"));
                n.setName(rs.getString("name"));
                n.setPrice(rs.getDouble("price"));
                n.setStock(rs.getInt("stock"));
                n.setType(rs.getString("type"));
                list.add(n);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean addNewspaper(Newspaper n) {
        String sql = "INSERT INTO newspaper(name, price, stock, type) VALUES(?,?,?,?)";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setString(1, n.getName());
            ps.setDouble(2, n.getPrice());
            ps.setInt(3, n.getStock());
            ps.setString(4, n.getType() != null ? n.getType() : "日报");
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateNewspaper(Newspaper n) {
        String sql = "UPDATE newspaper SET name=?, price=?, stock=?, type=? WHERE id=?";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setString(1, n.getName());
            ps.setDouble(2, n.getPrice());
            ps.setInt(3, n.getStock());
            ps.setString(4, n.getType());
            ps.setInt(5, n.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean deleteNewspaper(int id) {
        String sql = "DELETE FROM newspaper WHERE id=?";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // ==================== 发行区域 ====================
    public ArrayList<DeliveryArea> listDeliveryAreas() {
        ArrayList<DeliveryArea> list = new ArrayList<>();
        String sql = "SELECT da.*, d.name AS deliverer_name, c.name AS community_name " +
                     "FROM delivery_area da " +
                     "JOIN deliverer d ON da.deliverer_id = d.id " +
                     "JOIN community c ON da.community_id = c.id ORDER BY da.id";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                DeliveryArea da = new DeliveryArea();
                da.setId(rs.getInt("id"));
                da.setDelivererId(rs.getInt("deliverer_id"));
                da.setCommunityId(rs.getInt("community_id"));
                da.setAssignedDate(rs.getString("assigned_date"));
                da.setDelivererName(rs.getString("deliverer_name"));
                da.setCommunityName(rs.getString("community_name"));
                list.add(da);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean addDeliveryArea(DeliveryArea da) {
        String sql = "INSERT INTO delivery_area(deliverer_id, community_id, assigned_date) VALUES(?,?,?)";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql)) {
            ps.setInt(1, da.getDelivererId());
            ps.setInt(2, da.getCommunityId());
            ps.setString(3, da.getAssignedDate());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // ==================== 订阅管理（含事务演示） ====================
    public ArrayList<Subscription> listSubscriptions() {
        ArrayList<Subscription> list = new ArrayList<>();
        // 使用视图 v_subscription_detail
        String sql = "SELECT * FROM v_subscription_detail ORDER BY sub_id";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Subscription s = new Subscription();
                s.setId(rs.getInt("sub_id"));
                s.setCustomerName(rs.getString("customer_name"));
                s.setCommunityName(rs.getString("community_name"));
                s.setNewspaperName(rs.getString("newspaper_name"));
                s.setQuantity(rs.getInt("quantity"));
                s.setStartDate(rs.getString("start_date"));
                s.setEndDate(rs.getString("end_date") != null ? rs.getString("end_date") : "");
                s.setStatus(rs.getString("status"));
                s.setTotalAmount(rs.getDouble("total_amount"));
                list.add(s);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * 新增订阅 + 扣减库存（同一事务）
     */
    public boolean addSubscription(int customerId, int newspaperId, int quantity, String startDate) {
        Connection ct = null;
        try {
            ct = getConnection();
            ct.setAutoCommit(false);
            // 1. 插入订阅
            String sql1 = "INSERT INTO subscription(customer_id, newspaper_id, quantity, start_date, status) VALUES(?,?,?,?,'订阅中')";
            try (PreparedStatement ps = ct.prepareStatement(sql1)) {
                ps.setInt(1, customerId);
                ps.setInt(2, newspaperId);
                ps.setInt(3, quantity);
                ps.setString(4, startDate);
                ps.executeUpdate();
            }
            // 2. 扣减库存
            String sql2 = "UPDATE newspaper SET stock = stock - ? WHERE id = ? AND stock >= ?";
            try (PreparedStatement ps = ct.prepareStatement(sql2)) {
                ps.setInt(1, quantity);
                ps.setInt(2, newspaperId);
                ps.setInt(3, quantity);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    ct.rollback();
                    return false; // 库存不足
                }
            }
            ct.commit();
            return true;
        } catch (Exception e) {
            if (ct != null) { try { ct.rollback(); } catch (SQLException ex) {} }
            e.printStackTrace();
            return false;
        } finally {
            if (ct != null) { try { ct.setAutoCommit(true); ct.close(); } catch (SQLException ex) {} }
        }
    }

    /**
     * 【高阶技术5：事务】退订+新建订阅 在同一事务中
     * 演示 ACID 特性：全部成功或全部回滚
     */
    public String unsubscribeAndResubscribe(int oldSubId, int newCustomerId, int newNewspaperId, int newQuantity, String startDate) {
        Connection ct = null;
        try {
            ct = getConnection();
            ct.setAutoCommit(false);
            ct.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);

            // 步骤1：退订旧订阅
            String sql1 = "UPDATE subscription SET status='已退订', end_date=CURDATE() WHERE id=?";
            try (PreparedStatement ps = ct.prepareStatement(sql1)) {
                ps.setInt(1, oldSubId);
                ps.executeUpdate();
            }

            // 步骤2：创建新订阅
            String sql2 = "INSERT INTO subscription(customer_id, newspaper_id, quantity, start_date, status) VALUES(?,?,?,?,'订阅中')";
            try (PreparedStatement ps = ct.prepareStatement(sql2)) {
                ps.setInt(1, newCustomerId);
                ps.setInt(2, newNewspaperId);
                ps.setInt(3, newQuantity);
                ps.setString(4, startDate);
                ps.executeUpdate();
            }

            // 步骤3：扣减新报纸库存
            String sql3 = "UPDATE newspaper SET stock = stock - ? WHERE id = ? AND stock >= ?";
            try (PreparedStatement ps = ct.prepareStatement(sql3)) {
                ps.setInt(1, newQuantity);
                ps.setInt(2, newNewspaperId);
                ps.setInt(3, newQuantity);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    ct.rollback();
                    return "FAILED: 库存不足，事务已回滚";
                }
            }

            ct.commit();
            return "SUCCESS";
        } catch (Exception e) {
            if (ct != null) {
                try { ct.rollback(); } catch (SQLException ex) {}
            }
            e.printStackTrace();
            return "FAILED: " + e.getMessage();
        } finally {
            if (ct != null) {
                try { ct.setAutoCommit(true); ct.close(); } catch (SQLException e) {}
            }
        }
    }

    /**
     * 退订 + 恢复库存（同一事务）
     */
    public boolean cancelSubscription(int id) {
        Connection ct = null;
        try {
            ct = getConnection();
            ct.setAutoCommit(false);
            // 1. 查出该订阅的报纸ID和数量
            String sql0 = "SELECT newspaper_id, quantity FROM subscription WHERE id=? AND status='订阅中'";
            int newspaperId, quantity;
            try (PreparedStatement ps = ct.prepareStatement(sql0)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) { ct.rollback(); return false; }
                    newspaperId = rs.getInt("newspaper_id");
                    quantity = rs.getInt("quantity");
                }
            }
            // 2. 更新订阅状态为已退订
            String sql1 = "UPDATE subscription SET status='已退订', end_date=CURDATE() WHERE id=?";
            try (PreparedStatement ps = ct.prepareStatement(sql1)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            // 3. 恢复库存
            String sql2 = "UPDATE newspaper SET stock = stock + ? WHERE id=?";
            try (PreparedStatement ps = ct.prepareStatement(sql2)) {
                ps.setInt(1, quantity);
                ps.setInt(2, newspaperId);
                ps.executeUpdate();
            }
            ct.commit();
            return true;
        } catch (Exception e) {
            if (ct != null) { try { ct.rollback(); } catch (SQLException ex) {} }
            e.printStackTrace();
            return false;
        } finally {
            if (ct != null) { try { ct.setAutoCommit(true); ct.close(); } catch (SQLException ex) {} }
        }
    }

    // ==================== 【高阶技术1】存储过程调用 ====================
    /**
     * 调用 sp_monthly_stats，返回输出参数
     */
    public Map<String, Object> callMonthlyStats(int month, int year) {
        Map<String, Object> result = new HashMap<>();
        try (Connection ct = getConnection();
             CallableStatement cs = ct.prepareCall("{CALL sp_monthly_stats(?,?,?,?,?)}")) {
            cs.setInt(1, month);
            cs.setInt(2, year);
            cs.registerOutParameter(3, Types.INTEGER);
            cs.registerOutParameter(4, Types.INTEGER);
            cs.registerOutParameter(5, Types.DECIMAL);
            cs.execute();
            result.put("totalCustomers", cs.getInt(3));
            result.put("totalSubscriptions", cs.getInt(4));
            result.put("totalRevenue", cs.getDouble(5));
        } catch (Exception e) { e.printStackTrace(); }
        return result;
    }

    /**
     * 调用 sp_deliverer_performance，返回发行员业绩列表
     */
    public ArrayList<Map<String, Object>> callDelivererPerformance(int year) {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        try (Connection ct = getConnection();
             CallableStatement cs = ct.prepareCall("{CALL sp_deliverer_performance(?)}")) {
            cs.setInt(1, year);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("delivererName", rs.getString("deliverer_name"));
                    row.put("customerCount", rs.getInt("customer_count"));
                    row.put("subscriptionCount", rs.getInt("subscription_count"));
                    row.put("totalRevenue", rs.getDouble("total_revenue"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ==================== 【高阶技术3】视图查询 ====================
    /**
     * 查询发行员工作量视图
     */
    public ArrayList<Map<String, Object>> queryDelivererWorkload() {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM v_deliverer_workload ORDER BY deliverer_id";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("delivererId", rs.getInt("deliverer_id"));
                row.put("delivererName", rs.getString("deliverer_name"));
                row.put("phone", rs.getString("phone"));
                row.put("status", rs.getString("status"));
                row.put("communityCount", rs.getInt("community_count"));
                row.put("customerCount", rs.getInt("customer_count"));
                row.put("subscriptionCount", rs.getInt("subscription_count"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ==================== 【高阶技术7】窗口函数 ====================
    /**
     * 各社区报纸订阅排名：使用 RANK() OVER(PARTITION BY)
     */
    public ArrayList<Map<String, Object>> querySubscriptionRanking() {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT community_name, newspaper_name, sub_count, " +
                     "RANK() OVER(PARTITION BY community_name ORDER BY sub_count DESC) AS ranking " +
                     "FROM ( " +
                     "  SELECT com.name AS community_name, n.name AS newspaper_name, COUNT(*) AS sub_count " +
                     "  FROM subscription s " +
                     "  JOIN customer c ON s.customer_id = c.id " +
                     "  JOIN community com ON c.community_id = com.id " +
                     "  JOIN newspaper n ON s.newspaper_id = n.id " +
                     "  WHERE s.status = '订阅中' " +
                     "  GROUP BY com.name, n.name " +
                     ") t ORDER BY community_name, ranking";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("communityName", rs.getString("community_name"));
                row.put("newspaperName", rs.getString("newspaper_name"));
                row.put("subCount", rs.getInt("sub_count"));
                row.put("ranking", rs.getInt("ranking"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * 各报纸累计订阅量（窗口函数：SUM OVER）
     */
    public ArrayList<Map<String, Object>> queryCumulativeSubscriptions() {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT n.name AS newspaper_name, s.start_date, " +
                     "SUM(s.quantity) OVER(PARTITION BY n.name ORDER BY s.start_date) AS cumulative_qty " +
                     "FROM subscription s JOIN newspaper n ON s.newspaper_id = n.id " +
                     "WHERE s.status = '订阅中' ORDER BY n.name, s.start_date";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("newspaperName", rs.getString("newspaper_name"));
                row.put("startDate", rs.getString("start_date"));
                row.put("cumulativeQty", rs.getInt("cumulative_qty"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ==================== 审计日志查询 ====================
    public ArrayList<Map<String, Object>> listAuditLogs() {
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM audit_log ORDER BY id DESC LIMIT 50";
        try (Connection ct = getConnection();
             PreparedStatement ps = ct.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("tableName", rs.getString("table_name"));
                row.put("operation", rs.getString("operation"));
                row.put("recordId", rs.getInt("record_id"));
                row.put("oldData", rs.getString("old_data") != null ? rs.getString("old_data") : "");
                row.put("newData", rs.getString("new_data") != null ? rs.getString("new_data") : "");
                row.put("operateTime", rs.getString("operate_time"));
                row.put("operator", rs.getString("operator"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ==================== 索引性能对比测试 ====================
    /**
     * 【高阶技术4】索引性能对比：带索引查询 vs 全表扫描
     */
    public Map<String, Object> benchmarkIndexPerformance() {
        Map<String, Object> result = new HashMap<>();
        try (Connection ct = getConnection()) {
            // 测试1：使用索引查询（通过 customer_id + newspaper_id）
            long start1 = System.nanoTime();
            String sql1 = "SELECT * FROM subscription WHERE customer_id=1 AND newspaper_id=1";
            try (PreparedStatement ps = ct.prepareStatement(sql1);
                 ResultSet rs = ps.executeQuery()) { while (rs.next()) {} }
            long time1 = System.nanoTime() - start1;

            // 测试2：全表扫描（LIKE 无索引查询）
            long start2 = System.nanoTime();
            String sql2 = "SELECT * FROM subscription WHERE status='订阅中'";
            try (PreparedStatement ps = ct.prepareStatement(sql2);
                 ResultSet rs = ps.executeQuery()) { while (rs.next()) {} }
            long time2 = System.nanoTime() - start2;

            // 测试3：使用 EXPLAIN 分析
            StringBuilder explainResult = new StringBuilder();
            String explainSql = "EXPLAIN SELECT * FROM subscription WHERE customer_id=1 AND newspaper_id=1";
            try (PreparedStatement ps = ct.prepareStatement(explainSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    explainResult.append("type=").append(rs.getString("type"))
                        .append(", key=").append(rs.getString("key"))
                        .append(", rows=").append(rs.getInt("rows")).append("; ");
                }
            }

            result.put("indexedQuery_ns", time1);
            result.put("fullScanQuery_ns", time2);
            result.put("explainResult", explainResult.toString());
            result.put("ratio", String.format("%.2f", (double) time2 / time1));
        } catch (Exception e) { e.printStackTrace(); }
        return result;
    }

    // ==================== 辅助映射方法 ====================
    private SysUser mapSysUser(ResultSet rs) throws SQLException {
        SysUser u = new SysUser();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setRole(rs.getString("role"));
        u.setCreatedAt(rs.getString("created_at"));
        return u;
    }

    private Customer mapCustomer(ResultSet rs) throws SQLException {
        Customer c = new Customer();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setPhone(rs.getString("phone"));
        c.setAddress(rs.getString("address"));
        c.setCommunityId(rs.getInt("community_id"));
        c.setCommunityName(rs.getString("community_name") != null ? rs.getString("community_name") : "");
        return c;
    }

    private Deliverer mapDeliverer(ResultSet rs) throws SQLException {
        Deliverer d = new Deliverer();
        d.setId(rs.getInt("id"));
        d.setName(rs.getString("name"));
        d.setPhone(rs.getString("phone"));
        d.setIdCard(rs.getString("id_card"));
        d.setStatus(rs.getString("status"));
        return d;
    }
}
