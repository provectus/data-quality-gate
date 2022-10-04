from jira import JIRA

# Variables block
baseUrl = 'https://provectus-dev.atlassian.net'
username = 'ogorbachenko@provectus.com'
token = '8eEf5MuJYmBFlNYr9ySIBB5C'

options = {'server': baseUrl}
jira = JIRA(options, basic_auth=(username, token))


def get_all_bugs(project: str):
    got = 50
    total = 0
    while got == 50:
        issues = jira.search_issues('project=' + project, startAt=total)
        for singleIssue in issues:
            if str(singleIssue.fields.issuetype) == "Bug":
                print('{}: {}:{}'.format(singleIssue.key, singleIssue.fields.summary,
                                         singleIssue.fields.reporter.displayName))
        got = len(issues)
        total += got


def create_bug(project_key: str, table_name: str, column_name: str):
    summary = "[DataQA]: Auto generated bug for data test for table " + table_name + " for column: " + column_name
    print(summary)
    got = 50
    total = 0
    ticketExist = False
    while got == 50:
        issues = jira.search_issues('project=' + project_key, startAt=total)
        for singleIssue in issues:
            if str(singleIssue.fields.issuetype) == "Bug":
                if summary == str(singleIssue.fields.summary):
                    if str(singleIssue.fields.status) == 'Open':
                        print("Issue already exist and open")
                        ticketExist = True
                        break
                    if str(singleIssue.fields.status) == 'Done' or str(
                            singleIssue.fields.status) == 'Closed' or str(
                        singleIssue.fields.status) == 'Cancelled':
                        print("Issue closed, try to reopen")
                        print(singleIssue.key)
                        jira.transition_issue(singleIssue.key, transition='19')
                        ticketExist = True
                        break
        got = len(issues)
        total += got
    if not ticketExist:
        print("Issue not found, try to create new")
        jira.create_issue(
            fields={
                "project": {"key": project_key},
                "issuetype": {"name": "Bug"},
                "summary": summary,
                "description": "Auto generated bug for data test for table " + table_name,
            }
        )


if __name__ == '__main__':
    create_bug("IPA", "TableName", "ColumnName")
