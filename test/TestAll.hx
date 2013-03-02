import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
		runner.addCase(new thx.react.TestBinder());
		runner.addCase(new thx.react.TestDispatcher());
		runner.addCase(new thx.react.TestDeferred());
		runner.addCase(new thx.react.TestDeferred2());
	}

	public static function main()
	{
		var runner = new Runner();
		addTests(runner);
		Report.create(runner);
		runner.run();
	}
}
