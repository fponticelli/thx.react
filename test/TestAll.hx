import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
		runner.addCase(new thx.react.TestDispatcher());
		runner.addCase(new thx.react.TestDispatcher2());
		runner.addCase(new thx.react.TestDeferred());
	}

	public static function main()
	{
		var runner = new Runner();
		addTests(runner);
		Report.create(runner);
		runner.run();
	}
}
