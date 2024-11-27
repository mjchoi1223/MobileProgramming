import 'package:flutter/material.dart';
import 'income_screen.dart';
import 'expense_screen.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // 수입/지출 데이터를 관리할 리스트
  List<Map<String, dynamic>> transactions = [];

  // 빈 화면 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        '데이터가 없습니다.\n새로운 거래를 추가해보세요!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  // 데이터 리스트 화면 위젯
  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isExpense = transaction['type'] == 'expense';

        return ListTile(
          leading: Icon(
            isExpense ? Icons.remove : Icons.add,
            color: isExpense ? Colors.red : Colors.green,
          ),
          title: Text(transaction['category']),
          subtitle: Text('${transaction['date']} | ${transaction['memo']}'),
          trailing: Text(
            '${isExpense ? '-' : '+'}${transaction['amount']}원',
            style: TextStyle(
              color: isExpense ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  // 데이터 추가 처리 함수
  Future<void> _addTransaction(BuildContext context, bool isExpense) async {
    // 수입 또는 지출 화면으로 이동하고 결과를 기다림
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isExpense ? ExpenseScreen() : IncomeScreen(),
      ),
    );

    // 결과를 리스트에 추가
    if (result != null) {
      setState(() {
        transactions.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가계부'),
      ),
      body: transactions.isEmpty ? _buildEmptyState() : _buildTransactionList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "income",
            onPressed: () => _addTransaction(context, false), // 수입 추가
            child: Icon(Icons.add),
            tooltip: '수입 추가',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "expense",
            onPressed: () => _addTransaction(context, true), // 지출 추가
            child: Icon(Icons.remove),
            tooltip: '지출 추가',
          ),
        ],
      ),
    );
  }
}
