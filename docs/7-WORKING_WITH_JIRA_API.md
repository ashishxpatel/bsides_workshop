# Working with the Jira API
Working with Jira through the Python SDK is pretty straightforward. We should have already installed it above with `pip install jira`. Check the full SDK documentation at: https://jira.readthedocs.io/en/master/

### Keep secrets separate
Secrets management is hard. But for our simple usecase, we can put our secrets in a separate Python file and import it into our other files. This way we can keep all of our code in a git repo without exposing secrest.

```python
""" settings.py """
jira_url = "$URL"
jira_username = "$USERNAME"
jira_password = "$PASSWORD"
```

### Creating an issue



1) Configure Splunk alert for when the above lambda runs

2) Walk through creating tickets from SNS (local or on EC2):


```python
import jira

j = jira.JIRA(
    settings.jira_url,
    basic_auth=(settings.jira_username, settings.jira_password),
)
```

```
In [14]: j.projects()
Out[14]: [<JIRA Project: key='MOS', name='MosesProject1', id='10000'>]
```

```python
issue = j.create_issue(
    project=settings.jira_project,
    summary="Hello, world!",
    description="Insert description here",
    issuetype="Task",
)

print(issue)
print(issue.fields.summary)
print(issue.fields.comment.comments)
```

```
In [10]: i.fields.comment.comments
Out[10]: []

In [22]: j.add_comment("MOS-1", "Hello, comment!")
Out[22]: <JIRA Comment: id='10000'>

In [25]: i.update()

In [26]: i.fields.comment.comments
Out[26]: [<JIRA Comment: id='10000'>, <JIRA Comment: id='10001'>]
```

while 1:
    # FIXME: Consume from SNS queue
    if SNS_event:
      create_jira_issue("fixme", "fixme")
```
