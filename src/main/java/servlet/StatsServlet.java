package servlet;

import db.DB;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Map;

public class StatsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        String action = req.getParameter("action");
        DB db = new DB();

        switch (action != null ? action : "") {
            case "monthly":
                // 存储过程：月度统计
                Map<String, Object> stats = db.callMonthlyStats(6, 2026);
                req.setAttribute("monthlyStats", stats);
                break;
            case "deliverer":
                // 存储过程：发行员业绩
                req.getSession().setAttribute("delivererPerf", db.callDelivererPerformance(2026));
                break;
            case "workload":
                // 视图：工作量视图
                req.getSession().setAttribute("workload", db.queryDelivererWorkload());
                break;
            case "ranking":
                // 窗口函数：订阅排名
                req.getSession().setAttribute("ranking", db.querySubscriptionRanking());
                break;
            case "cumulative":
                // 窗口函数：累计订阅
                req.getSession().setAttribute("cumulative", db.queryCumulativeSubscriptions());
                break;
            case "index":
                // 索引性能对比
                Map<String, Object> bench = db.benchmarkIndexPerformance();
                req.setAttribute("benchmark", bench);
                break;
            case "audit":
                // 审计日志
                req.getSession().setAttribute("auditLogs", db.listAuditLogs());
                break;
        }
        req.getRequestDispatcher("stats.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
