<?php
// إعدادات الاتصال بقاعدة البيانات على XAMPP (root بلا كلمة مرور افتراضياً).
class Database {
    private $host     = '127.0.0.1';
    private $db_name  = 'edufun_db';
    private $username = 'root';
    private $password = '';
    private $charset  = 'utf8mb4';
    public  $conn;

    public function connect() {
        $this->conn = null;
        try {
            $dsn = "mysql:host={$this->host};dbname={$this->db_name};charset={$this->charset}";
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ];
            $this->conn = new PDO($dsn, $this->username, $this->password, $options);
            $this->conn->exec("SET NAMES utf8mb4");
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'فشل الاتصال بقاعدة البيانات: ' . $e->getMessage()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        return $this->conn;
    }
}
