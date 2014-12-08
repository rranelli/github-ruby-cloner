module GitMulticast
  describe Cloner do
    subject(:cloner) { described_class.new(username, dir) }

    let(:username) { 'rranelli' }
    let(:dir) { '/kifita/' }

    let(:repo_name) { 'git_multicast' }

    before do
      allow(task).to receive(:spawn)
        .and_return(pid)
      allow(task).to receive(:wait)
        .and_return(['', 0])

      allow(Task).to receive(:new)
        .and_return(task)
    end

    let(:task) { instance_double(Task, call: result) }
    let(:result) { TaskResult.new(repo_name, 'success', 0) }

    let(:pid) { 42 }

    describe '#clone!' do
      subject(:clone!) { cloner.clone! }

      it do
        VCR.use_cassette('clone_repos') do
          expect(RepositoryFetcher).to receive(:get_all_repos_from_user)
            .with(username)
            .and_call_original

          clone!
        end
      end

      it 'creates a task for each fetched repository' do
        VCR.use_cassette('clone_repos') do
          expect(Task).to receive(:new).exactly(43).times

          clone!
        end
      end

      it 'creates a task runner and asks it to run all tasks' do
        VCR.use_cassette('clone_repos') do
          expect(TaskRunner).to receive_message_chain(:new, :run!)

          clone!
        end
      end

      it 'spawns a clone job for each repo' do
        VCR.use_cassette('clone_repos') do
          expect(task).to receive(:call).exactly(43).times

          clone!
        end
      end

      it 'spawns a clone with the right parameters' do
        VCR.use_cassette('clone_repos') do
          clone_command = "git clone git@github.com:rranelli/#{repo_name}.git" \
            ' /kifita/git_multicast'

          expect(Task).to receive(:new)
            .with(repo_name, clone_command)

          clone!
        end
      end

      context 'when repo is a fork'do
        let(:repo_name) { 'emacs.d' }

        it 'adds upstream remote' do
          VCR.use_cassette('clone_repos') do
            expect(Task).to receive(:new)
              .with(
              repo_name,
              "git clone git@github.com:rranelli/#{repo_name}.git " \
              "/kifita/#{repo_name} && git -C \"/kifita/#{repo_name}\"" \
              ' remote add upstream ' \
              "git@github.com:purcell/#{repo_name}.git --fetch"
              )

            clone!
          end
        end
      end
    end
  end
end
